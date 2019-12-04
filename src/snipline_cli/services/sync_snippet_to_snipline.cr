require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class SyncSnippetToSnipline

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def self.handle(snippet)
      # snippet = Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
      response = SniplineApi.new.create(snippet)
      if snippet.is_a?(SnippetSchema)
        snippet = Repo.get!(SnippetSchema, snippet.as(SnippetSchema).local_id)
        snippet.cloud_id = response.id
        Repo.update(snippet)
      end
      response
    end
  end
end
