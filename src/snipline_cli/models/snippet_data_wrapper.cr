require "json"

module SniplineCli
  class SnippetDataWrapper
    JSON.mapping({
      data: Array(Snippet),
    })
  end

  class SingleSnippetDataWrapper
    JSON.mapping({
      data: Snippet,
    })
  end

  class SnippetError
    JSON.mapping({
      detail: String,
      source: Hash(String, String),
      title:  String,
    })
  end

  class SnippetErrorResponse
    JSON.mapping({
      errors: Array(SnippetError),
    })

    def has_key?(key)
      @errors.any? { |error|
        error.source["pointer"] == "/data/attributes/#{key}"
      }
    end
  end
end
