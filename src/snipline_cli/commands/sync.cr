require "json"
require "colorize"
require "file_utils"
require "toml"

module SniplineCli
  class Command < Admiral::Command
    # The command to sync your snippets with your active Snipline account.
    #
    # ```bash
    # snipcli sync
    # ```
    class Sync < Admiral::Command
      define_help description: "For syncing snippets from Snipline"
      define_flag verbose : Bool, default: false, long: verbose
      define_flag dry_run : Bool, default: false, description: "Output the changes that would be made if the command was run without --dry-run"

      property snipline_api : (SniplineApi | SniplineApiTest) = SniplineApi.new
      property file : (StoreSnippets) = StoreSnippets.new

      def run
				puts "Migrating Database..." if flags.verbose
        Migrator.run
				puts "Syncing snippets..." if flags.verbose
        config = SniplineCli.config
        if config.get("api.token") == ""
          abort("#{"No API token. Run".colorize(:red)} #{"snipcli login".colorize(:red).mode(:bold)} #{"to login".colorize(:red)}")
        end

        sync_unsynced_snippets
        @snipline_api.fetch do |body|
          cloud_snippets = SnippetDataParser.from_json(body).data
          save_new_snipline_cloud_snippets(cloud_snippets)
          delete_orphan_snippets(cloud_snippets)
          update_locally_out_of_date_snippets(cloud_snippets)
        end
      end

      def update_locally_out_of_date_snippets(cloud_snippets)
        synced_to_local_count = 0
        synced_to_cloud_count = 0
        cloud_snippets.each { |cs|
          local_snippet = Repo.get_by(Snippet, cloud_id: cs.id.not_nil!)
          if local_snippet
            if local_snippet.is_synced
              # local hasn't changed - redownload from snipline just incase
              local_snippet.name = cs.not_nil!.name.not_nil!
              local_snippet.real_command = cs.not_nil!.real_command.not_nil!
              local_snippet.documentation = cs.not_nil!.documentation
              local_snippet.snippet_alias = cs.not_nil!.snippet_alias
              local_snippet.is_synced = true
              local_snippet.is_pinned = cs.not_nil!.is_pinned
							Repo.update(local_snippet) unless flags.dry_run
              synced_to_local_count = synced_to_local_count + 1
            else
              # local has updated without sending to snipline cloud - time to update the cloud version
							@snipline_api.update(local_snippet) unless flags.dry_run
              synced_to_cloud_count = synced_to_cloud_count + 1
            end
          end
        }
				puts "Synced #{synced_to_local_count} from Snipline Cloud to local database".colorize(:green)
        puts "Synced #{synced_to_cloud_count} from local database to Snipline Cloud".colorize(:green)
      end

      def delete_orphan_snippets(cloud_snippets)
        # if snippet cloud_id exists locally but not in cloud
				puts "Cleaning up snippets that are no longer in Snipline Cloud..." if (flags.verbose || flags.dry_run)
        local_snippets = LoadSnippets.run.select { |ls| !ls.cloud_id.nil? }
        orphans = [] of Snippet
        cloud_snippet_ids = cloud_snippets.map { |s| s.not_nil!.id }
        local_snippets.each do |ls|
          orphans << ls unless cloud_snippet_exists?(ls, cloud_snippet_ids)
        end
        orphans.each do |ls|
          # delete snippets
					puts "Deleting #{ls.name}".colorize(:green) if (flags.verbose || flags.dry_run)
					Repo.delete(ls) unless flags.dry_run
        end
      end

      def cloud_snippet_exists?(local_snippet, cloud_snippet_ids)
        cloud_snippet_ids.includes?(local_snippet.cloud_id.not_nil!)
      end

      def save_new_snipline_cloud_snippets(cloud_snippets)
        # Save the response JSON into a file without the data wrapper
        local_snippets = LoadSnippets.run
        begin
          # Only snippets that are in the cloud but not stored locally
          difference = [] of SnippetParser
          local_snippet_cloud_ids = local_snippets.select { |s| !s.cloud_id.nil? }.map { |s| s.cloud_id.not_nil! }
          cloud_snippets.each do |cs|
            difference << cs unless local_snippet_exists?(cs, local_snippet_cloud_ids)
          end
          difference.each do |s|
						puts "Storing #{s.attributes.name} from Snipline Cloud".colorize(:green) if (flags.verbose || flags.dry_run)
            snippet = Snippet.new
            snippet.name = s.name
            snippet.cloud_id = s.id
            snippet.real_command = s.real_command
            snippet.documentation = s.documentation
            snippet.tags = (s.tags.nil?) ? nil : s.tags.not_nil!.join(",")
            snippet.snippet_alias = s.snippet_alias
            snippet.is_pinned = s.is_pinned
            snippet.is_synced = true
            changeset = Snippet.changeset(snippet)
						Repo.insert(changeset) unless flags.dry_run
            # local_snippets << s
          end
          # @file.store(local_snippets.to_json) unless difference.size == 0
        rescue ex
          puts ex.message.colorize(:red)
        end
      end

      def local_snippet_exists?(cs, local_snippet_ids)
        if cs.id.nil?
          false
        else
          local_snippet_ids.includes?(cs.id.not_nil!)
        end
      end

      def sync_unsynced_snippets
        local_snippets = LoadSnippets.run
        local_snippets.select { |s| s.cloud_id.nil? }.each do |snippet|
					puts "Attempting to store #{snippet.name.colorize.mode(:bold)} in Snipline..." if (flags.verbose || flags.dry_run)
          begin
						cloud_snippet = SyncSnippetToSnipline.handle(snippet) unless flags.dry_run
            update_local_snippet_id(cloud_snippet, snippet)
						puts "#{snippet.name.colorize(:green).mode(:bold)} #{"saved successfully!".colorize(:green)}" if (flags.verbose || flags.dry_run)
          rescue ex : Crest::UnprocessableEntity
            resp = SnippetErrorResponse.from_json(ex.response.not_nil!.body)
            puts "Failed: #{resp.errors.first.source["pointer"].gsub("/data/attributes/", "")} #{resp.errors.first.detail}".colorize(:red)
          rescue ex
            abort ex.message
          end
        end
      end

      def update_local_snippet_id(cloud_snippet, local_snippet)
				if cloud_snippet
					local_snippet.cloud_id = cloud_snippet.id
					local_snippet.is_synced = true
					Repo.update(local_snippet) unless flags.dry_run
					puts "Updated cloud_id of #{local_snippet.name.as(String)} to #{cloud_snippet.id}" if (flags.verbose || flags.dry_run)
				end
      end
    end

    register_sub_command :sync, Sync
  end
end
