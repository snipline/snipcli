require "toml"

module SniplineCli
  class Command < Admiral::Command
    # The command to initialize Snipline CLI without an active Snipline account.
    #
    # This command generates a config file in the requested location.
    # By default this location is ~/.config/snipline/config.toml
    class New < Admiral::Command
      define_help description: "Create a new Snippet"

      def run
        config = SniplineCli.config
        unless File.exists?(File.expand_path("#{config.get("general.db")}", home: true))
          abort("Database does not exist - Have you tried running #{"snipcli init".colorize.mode(:bold)}?".colorize.back(:red).on(:red))
        end
        Migrator.run
        unless ENV.has_key?("EDITOR")
          abort("Please set your environment EDITOR variable. E.g. export EDITOR=vi".colorize.back(:red).on(:red))
        end
        temp_file = TempSnippetEditorFile.new
        temp_file.create
        loop do
          system("#{ENV["EDITOR"]} #{File.expand_path("#{config.get("general.temp_dir")}/temp.toml", home: true)}")
          snippet_attributes = temp_file.read
          snippet = Snippet.new

          snippet.name = snippet_attributes.name
          snippet.real_command = snippet_attributes.real_command
          snippet.documentation = snippet_attributes.documentation
          snippet.tags = (snippet_attributes.tags.nil?) ? nil : snippet_attributes.tags.not_nil!.join(",")
          snippet.snippet_alias = snippet_attributes.snippet_alias
          snippet.is_pinned = snippet_attributes.is_pinned
          snippet.is_synced = false
          changeset = Snippet.changeset(snippet)
          abort("Invalid") unless changeset.valid?
          result = Repo.insert(changeset)
          begin
            if temp_file.sync_to_cloud?
              SyncSnippetToSnipline.handle(result.instance)
            end
            puts "Snippet created!"
            temp_file.delete
            break
          rescue ex : Crest::UnprocessableEntity
            puts "Invalid data:".colorize.mode(:bold)
            snippet_errors = SnippetErrorResponse.from_json(ex.response.body)
            snippet_errors.errors.each do |error|
              puts "#{error.source["pointer"].gsub("/data/attributes/", "")}: #{error.title}".colorize.back(:red).on(:red)
            end
            puts "\r\nEdit Snippet? Y/n"
            repeat = gets
            break if repeat == "n"
          rescue ex : Crest::NotFound
            abort("404 API URL not found".colorize.back(:red).on(:red))
          rescue ex : Crest::InternalServerError
            abort("API Internal Server Error".colorize.back(:red).on(:red))
          rescue ex
            puts "#{ex.message}"
            abort("Connection to Snipline Cloud Refused".colorize.back(:red).on(:red))
          end
        end
      end
    end

    register_sub_command :new, New
  end
end
