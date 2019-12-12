require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class StoreSnippets
    # Takes an array of snippets and saves them to the `snippet.json` file.
    def store(snippets)
      config = SniplineCli.config
      directory = File.dirname(File.expand_path(config.get("general.file"), home: true))
      unless File.directory?(directory)
        puts "Creating #{directory} directory"
        Dir.mkdir(File.expand_path(directory, home: true))
      end
      File.write(File.expand_path(config.get("general.file"), home: true), snippets, mode: "w")
      unless File.writable?(File.expand_path(config.get("general.file"), home: true))
        raise Exception.new("Sync Failed: File not writable (#{config.get("general.file")}")
      end
    end
  end
end
