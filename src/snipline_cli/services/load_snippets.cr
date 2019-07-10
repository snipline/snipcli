module SniplineCli
  module Services
    # LoadSnippets fetches all the snippets from the `snippet.json` file and parses them.
    #
    # ```crystal
    # snippets = SniplineCli::Services::LoadSnippets.run
    # ```
    class LoadSnippets
      def self.run : Array(Snippet)
        config = SniplineCli.config
        log = SniplineCli.log
        log.info("Looking through file #{config.get("general.file")}")
        snippets = [] of Snippet
        unless File.readable?(File.expand_path(config.get("general.file")))
          log.warn("Could not read #{config.get("general.file")}")
          log.info("Run #{"snipline-cli sync".colorize(:green)} first")
          return snippets
        end
        File.open(File.expand_path(config.get("general.file"))) do |file|
          snippets = Array(Snippet).from_json(file)
        end

        snippets
      end
    end
  end
end
