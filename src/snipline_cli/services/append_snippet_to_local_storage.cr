require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class AppendSnippetToLocalStorage
    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet)
        snippets = SniplineCli::Services::LoadSnippets.run
        snippets << snippet
        SniplineCli::Services::StoreSnippets.new.store(snippets.to_json)
        return
    end
  end
end


