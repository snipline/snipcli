require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class SyncSnippetToSnipline
    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet_attributes)
        puts "TODO: Syncing..."
        Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
    end
  end
end

