require "../helpers/*"

module SniplineCli
  module Services
    include SniplineCli::Helpers

    # LoadSnippets fetches all the snippets from the `snippet.json` file and parses them.
    #
    # ```crystal
    # snippets = SniplineCli::Services::LoadSnippets.run
    # ```
    class LoadSnippets
      def self.run : Array(Snippet)
        config = SniplineCli.config
        log = SniplineCli.log
        log.info("Looking through file #{config.get("general.db")}")
        unless File.readable?(expand_path(config.get("general.db")))
          log.warn("Could not read #{config.get("general.db")}")
          abort("Run #{"snipline-cli sync".colorize(:green)} first")
        end
        # File.open(File.expand_path(config.get("general.db"))) do |file|
        #   snippets = Array(Snippet).from_json(file)
        # end
        Repo.all(Snippet)
      end
    end
  end
end
