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

        def params() : Array(SnippetParam)
            temp_array = [] of SnippetParam

            real_command.scan(/#(select)?\{\[(.+?)\]\}/) do |m|
                if m[1]? && m[1] == "select"
                    split_equals = m[2].split("=").map { |substring| substring}
                    param_name = split_equals.shift
                    unparsed_params = split_equals.join("=")
                    if unparsed_params.is_a?(String)
                        options = unparsed_params.as(String).split(",")
                        # todo
                        if options.is_a?(Array(String))
                            options = options.as(Array(String))
                        end
                    else
                        options = Array(String).new
                    end
                    # default_option = options.first || ""
                    temp_array << SnippetParam.new(param_name, "", m[2], "select", options)
                elsif m[2].includes?("=")
                    split_equals = m[2].split("=").map { |substring| substring }
                    param_name = split_equals.shift
                    default_value = split_equals.join("=")
                    temp_array << SnippetParam.new(param_name, default_value, m[2], "variable", Array(String).new)
                else
                    temp_array << SnippetParam.new(m[2], "", m[2], "variable", Array(String).new)
                end
            end
            return temp_array
        end

        def has_params
            params.size > 0
        end

        def preview_command
            # TODO: syntax highlight and display preview command
            unless has_params()
                return real_command
            end
            
            temp_command = real_command
            params.each do |param|
                if param.type == "select"
                    temp_command = temp_command.gsub("#select{[#{param.full}]}") { "<#{param.name}>".colorize(:green) }
                    temp_command = temp_command.gsub("#select{[#{param.name}]}") { "<#{param.name}>".colorize(:green) }
                else
                    temp_command = temp_command.gsub("\#{[#{param.full}]}") { "<#{param.name}>".colorize(:green) }
                    temp_command = temp_command.gsub("\#{[#{param.name}]}") { "<#{param.name}>".colorize(:green) }
                end
            end
            temp_command
        end
    end

    struct SnippetParam
        property name : String
        property default_value : String
        property full : String
        property type : String
        property options : Array(String)

        def initialize(@name : String, @default_value : String, @full : String, @type : String, @options : Array(String))
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