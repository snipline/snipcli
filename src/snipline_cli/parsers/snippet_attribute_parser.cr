require "json"

module SniplineCli::Parsers
  # Used for parsing JSON-API spec attributes.
  #
  # When a list of snippets comes from the API, there is an `attribute` attribute which contains most of the snippet properties (except id).
  class SnippetAttributeParser
    include JSON::Serializable

    @[JSON::Field(key: "alias")]
    property snippet_alias : String | Nil

    @[JSON::Field(key: "documentation")]
    property documentation : String | Nil

    @[JSON::Field(key: "is-pinned")]
    property is_pinned : Bool

    @[JSON::Field(key: "name")]
    property name : String

    @[JSON::Field(key: "real-command")]
    property real_command : String

    @[JSON::Field(key: "tags")]
    property tags : Array(String) | Nil

    @[JSON::Field(key: "updated-at")]
    property updated_at : String | Nil

    @[JSON::Field(key: "inserted-at")]
    property inserted_at : String | Nil

    def initialize(@name : String, @real_command : String, @documentation : String | Nil, @is_pinned : Bool, @snippet_alias : String | Nil, @tags : Array(String), @inserted_at : String | Nil, @updated_at : String | Nil)
    end

    def initialize(@name : String, @real_command : String, @documentation : String | Nil, @is_pinned : Bool, @snippet_alias : String | Nil, @tags : Array(String))
    end

    def set_timestamps
      self.inserted_at = Time.utc.to_s
      self.updated_at = Time.utc.to_s
    end
  end
end
