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
        unless File.exists?(File.expand_path("#{config.get("general.file")}"))
            abort("Config file does not exist - Have you tried running #{"snipcli init".colorize.mode(:bold)}?".colorize.back(:red).on(:red))
        end
        temp_file = SniplineCli::Services::TempSnippetEditorFile.new
        temp_file.create
        loop do
          system("#{ENV["EDITOR"]} #{File.expand_path("#{config.get("general.temp_dir")}/temp.toml")}")
          snippet_attributes = temp_file.read
          begin
            snippet = if config.get("general.sync_to_cloud")
                        SniplineCli::Services::SyncSnippetToSnipline.handle(snippet_attributes)
                      else
                        Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
                      end
            if snippet.is_a?(Snippet)
              SniplineCli::Services::AppendSnippetToLocalStorage.handle(snippet)
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
          rescue
            abort("Connection to Snipline Cloud Refused".colorize.back(:red).on(:red))
          end
        end
      end
    end

    register_sub_command :new, New
  end
end
