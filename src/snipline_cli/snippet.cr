require "json"

module SniplineCli
    class SnippetDataWrapper 
        JSON.mapping({
            data: Array(Snippet)
        })
    end
    class Snippet
        JSON.mapping({
            id: String,
            type: String,
            attributes: SnippetAttribute
        })
    end
    class SnippetAttribute
        include JSON::Serializable
        @[JSON::Field(key: "alias")]
        property alias : String | Nil

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
        # JSON.mapping({
        #     alias: String | Nil,
        #     documentation: String | Nil,
        #     is_pinned: Bool,
        #     name: String,
        #     # real_command: String,
        #     # tags: Array(String)
        # })
    end
end