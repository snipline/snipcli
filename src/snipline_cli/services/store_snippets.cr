require "json"

require "../helpers/*"

module SniplineCli::Services
  # For saving Snippets locally.
  class StoreSnippets
    include SniplineCli::Helpers

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def store(snippets)
      config = SniplineCli.config
      directory = File.dirname(expand_path(config.get("general.file")))
      unless File.directory?(directory)
        puts "Creating #{directory} directory"
        Dir.mkdir(expand_path(directory))
      end
      File.write(expand_path(config.get("general.file")), snippets, mode: "w")
      unless File.writable?(expand_path(config.get("general.file")))
        raise Exception.new("Sync Failed: File not writable (#{config.get("general.file")}")
      end
    end
  end
end
