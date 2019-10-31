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

      property snipline_api : (SniplineCli::Services::SniplineApi | SniplineCli::Services::SniplineApiTest) = SniplineCli::Services::SniplineApi.new
      property file : (SniplineCli::Services::StoreSnippets) = SniplineCli::Services::StoreSnippets.new

      def run
        puts "Syncing snippets..."
        config = SniplineCli.config
				if config.get("api.token") == ""
					abort("#{"No API token. Run".colorize(:red)} #{"snipcli login".colorize(:red).mode(:bold)} #{"to login".colorize(:red)}")
				end

				sync_unsaved_snippets
				download_snipline_snippets

      end


			def download_snipline_snippets
        @snipline_api.fetch do |body|
          # Save the response JSON into a file without the data wrapper
          cloud_snippets = Models::SnippetDataWrapper.from_json(body).data
					local_snippets = SniplineCli::Services::LoadSnippets.run
          begin
						# Only snippets that are in the cloud but not stored locally
						difference = [] of SniplineCli::Models::Snippet
						local_snippet_ids = local_snippets.map { |s| s.id }
						cloud_snippets.each do |cs|
							difference << cs unless local_snippet_exists?(cs, local_snippet_ids)
						end
						difference.each do |s|
							puts "Storing #{s.attributes.name} from Snipline".colorize(:green)
							local_snippets << s
						end
						@file.store(local_snippets.to_json) unless difference.size == 0
          rescue ex
						puts ex.message.colorize(:red)
          end
        end
			end

			def local_snippet_exists?(cs, local_snippet_ids)
				unless cs.id.nil?
					return local_snippet_ids.includes?(cs.id.not_nil!)
				end
				return false
			end

			def sync_unsaved_snippets
				local_snippets = SniplineCli::Services::LoadSnippets.run
				local_snippets.select { |s| s.id.nil? }.each do |snippet|
					puts "Attempting to store #{snippet.name.colorize.mode(:bold)} in Snipline..."
					begin
						cloud_snippet = SniplineCli::Services::SyncSnippetToSnipline.handle(snippet.attributes)
						update_local_snippet_id(cloud_snippet, local_snippets)
						puts "Success!".colorize(:green)
					rescue ex : Crest::UnprocessableEntity
						resp = SniplineCli::Models::SnippetErrorResponse.from_json(ex.response.not_nil!.body)
						puts "Failed: #{resp.errors.first.source["pointer"].gsub("/data/attributes/", "")} #{resp.errors.first.detail}".colorize(:red)
					rescue ex
						abort ex.message
					end
				end
			end

			def update_local_snippet_id(cloud_snippet, local_snippets)
				local_snippets = local_snippets.map do |snippet|
					if snippet.id.nil? && snippet.attributes.snippet_alias == cloud_snippet.attributes.snippet_alias && snippet.name == cloud_snippet.name
						snippet.id = cloud_snippet.id
						snippet.attributes.inserted_at = cloud_snippet.attributes.inserted_at
						snippet.attributes.updated_at = cloud_snippet.attributes.updated_at
					end
					snippet
				end
				@file.store(local_snippets.to_json)
			end
    end

    register_sub_command :sync, Sync
  end
end
