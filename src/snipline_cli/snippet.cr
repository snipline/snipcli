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

        def params
            # TODO: parse params and list them
            [] of String
        end

        def preview_command
            # TODO: syntax highlight and display preview command
            ""
        end
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

    end
end