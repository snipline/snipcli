require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class AppendSnippetToLocalStorage
    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet)
      snippets = SniplineCli::Services::LoadSnippets.run
      if snippet.is_a?(Snippet)
        snippets << snippet.as(Snippet)
      end
      SniplineCli::Services::StoreSnippets.new.store(snippets.to_json)
      return
    end
  end
end
