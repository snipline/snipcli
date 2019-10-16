require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class SyncSnippetToSnipline
    include SniplineCli::Models

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet_attributes)
      snippet = Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
      SniplineApi.new.create(snippet)
    end
  end
end
