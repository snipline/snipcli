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
        temp_file = SniplineCli::Services::TempSnippetEditorFile.new
        temp_file.create
        system("#{ENV["EDITOR"]} #{File.expand_path("#{config.get("general.temp_dir")}/temp.toml")}")
        snippet_attributes = temp_file.read
        begin
          snippet = if config.get("general.sync_to_cloud")
                      SniplineCli::Services::SyncSnippetToSnipline.handle(snippet_attributes)
                    else
                      Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
                    end
          unless snippet.is_a?(Snippet)
            SniplineCli::Services::AppendSnippetToLocalStorage.handle(snippet)
          end
          puts "Snippet created!"
          temp_file.delete
        rescue ex : Crest::UnprocessableEntity
          puts "Invalid data - see `snipcli new` for details"
          snippet_errors = SnippetErrorResponse.from_json(ex.response.body)
        rescue ex : Crest::NotFound
          puts "404 API URL not found"
        rescue ex : Crest::InternalServerError
          puts "API Internal Server Error"
        rescue
          puts "Connection to Snipline Cloud Refused"
        end
      end
    end

    register_sub_command :new, New
  end
end
