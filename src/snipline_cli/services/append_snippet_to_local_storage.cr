module SniplineCli::Services
  # For saving Snippets locally.
  class AppendSnippetToLocalStorage

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet)
      snippets = LoadSnippets.run
      if snippet.is_a?(Snippet)
        snippets << snippet
      end
      StoreSnippets.new.store(snippets.to_json)
      return
    end
  end
end
