require "../config/config"
require "./log"
module SniplineCli
  module Services
    class LoadSnippets
        def self.run : Array(Snippet)
            config = SniplineCli::Config.new
            log = SniplineCli::Services::Log.new
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

