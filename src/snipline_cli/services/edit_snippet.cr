module SniplineCli
  module Services
    # LoadSnippets fetches all the snippets from the `snippet.json` file and parses them.
    #
    # ```crystal
    # snippets = SniplineCli::Services::LoadSnippets.run
    # ```
    class EditSnippet
      def self.run(snippet : Snippet, input, output)
        config = SniplineCli.config
        log = SniplineCli.log
        log.info("editing snippet #{snippet.name}")
        temp_file = TempSnippetEditorFile.new(snippet)
        temp_file.create
        loop do
          system("#{ENV["EDITOR"]} #{File.expand_path("#{config.get("general.temp_dir")}/temp.toml", home: true)}")
          snippet_attributes = temp_file.read
          snippet.name = snippet_attributes.name
          snippet.real_command = snippet_attributes.real_command
          snippet.documentation = snippet_attributes.documentation
          snippet.tags = (snippet_attributes.tags.nil?) ? nil : snippet_attributes.tags.not_nil!.join(",")
          snippet.snippet_alias = snippet_attributes.snippet_alias
          snippet.is_pinned = snippet_attributes.is_pinned
          snippet.is_synced = false
          changeset = Snippet.changeset(snippet)
          if changeset.valid?
            begin
              if temp_file.sync_to_cloud?
                SniplineApi.new.update(snippet)
                temp_file.delete
                puts "Snippet updated!"
                break
              else
                changeset = Snippet.changeset(snippet)
                Repo.update(changeset)
                temp_file.delete
                puts "Snippet updated!"
                break
              end
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
          else
            puts "Invalid data:".colorize.mode(:bold)
            changeset.errors.each do |error|
              puts "#{error[:field]} #{error[:message]}".colorize.back(:red).on(:red)
            end
            puts "\r\nEdit Snippet? Y/n"
            repeat = gets
            break if repeat == "n"
          end
        end
      end
    end
  end
end
