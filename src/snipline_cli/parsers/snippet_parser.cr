require "json"

module SniplineCli::Parsers
  class SnippetParser
    JSON.mapping({
      id:         String | Nil,
      type:       String,
      attributes: SnippetAttributeParser,
    })

    def initialize(@id : String | Nil, @type : String, @attributes : SnippetAttributeParser)
    end

    def snippet_alias
      attributes.snippet_alias
    end

    def name
      attributes.name
    end

    def documentation
      attributes.documentation
    end

    def is_pinned
      attributes.is_pinned
    end

    def real_command
      attributes.real_command
    end

    def tags
      attributes.tags
    end

    def is_synced
      attributes.is_synced
    end

    def inserted_at
      attributes.inserted_at
    end

    def updated_at
      attributes.updated_at
    end

    def value_for_attribute(attribute : String)
      case attribute
      when "alias"
        snippet_alias || ""
      when "documentation"
        documentation || ""
      when "name"
        name || ""
      when "tags"
        if !tags.nil?
          tags.as(Array(String)).join(",") || ""
        else
          ""
        end
      else
        ""
      end
    end
  end
end
