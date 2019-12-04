module SniplineCli::Parsers
  class SnippetDataParser
    JSON.mapping({
      data: Array(SnippetParser),
    })
  end

  class SingleSnippetDataParser
    JSON.mapping({
      data: SnippetParser,
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

