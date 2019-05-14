require "json"

module SniplineCli
  class SnippetAttribute
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
    property tags : Array(String)
  end
end
