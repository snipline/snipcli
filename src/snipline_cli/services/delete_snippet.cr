module SniplineCli
  module Services
    # LoadSnippets fetches all the snippets from the `snippet.json` file and parses them.
    #
    # ```crystal
    # snippets = SniplineCli::Services::LoadSnippets.run
    # ```
    class DeleteSnippet
      def self.run(snippet : Snippet, input, output)
        log = SniplineCli.log
				puts "#{"Are you sure you want to permanently delete".colorize(:red)} #{snippet.name.colorize(:red).mode(:bold)}#{"? (y/N)".colorize(:red)}"
				answer = gets
				if ["Y", "y", "yes"].includes?(answer)
					delete_snippet(snippet)
				end
      end

			def self.delete_snippet(snippet)
        config = SniplineCli.config
				if snippet.cloud_id && config.get("api.token") != ""
					SniplineApi.new.delete(snippet)
				end
				Repo.delete(snippet)
				puts "Deleted #{snippet.name}".colorize(:green)
			end
    end
  end
end
