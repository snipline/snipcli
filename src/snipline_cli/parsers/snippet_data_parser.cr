module SniplineCli::Parsers
  class SnippetDataParser
		include JSON::Serializable

		@[JSON::Field(key: "data")]
		property data : Array(SnippetParser)
  end

  class SingleSnippetDataParser
		include JSON::Serializable

		@[JSON::Field(key: "data")]
		property data : SnippetParser
  end

  class SnippetError
		include JSON::Serializable

		@[JSON::Field(key: "detail")]
		property detail : String

		@[JSON::Field(key: "source")]
		property source : Hash(String, String)

		@[JSON::Field(key: "title")]
		property title : String
  end

  class SnippetErrorResponse
		include JSON::Serializable

		@[JSON::Field(key: "errors")]
		property errors : Array(SnippetError)

    def has_key?(key)
      @errors.any? { |error|
        error.source["pointer"] == "/data/attributes/#{key}"
      }
    end
  end
end
