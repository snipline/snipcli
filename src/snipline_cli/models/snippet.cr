require "json"

module SniplineCli
  class Snippet
    JSON.mapping({
      id:         String,
      type:       String,
      attributes: SnippetAttribute,
    })

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

    #
    # Params such as variables or select that require input from the user
    #
    def interactive_params : Array(SnippetParam)
      temp_array = [] of SnippetParam

      real_command.scan(/#(select)?\{\[(.+?)\]\}/) do |m|
        param_type = (m[1]?) ? m[1] : "variable"
        if temp_array.select { |param| param.name == m[2] && param_type == param.type }.size == 0
          if param_type == "select"
            split_equals = m[2].split("=").map { |substring| substring }
            param_name = split_equals.shift
            unparsed_params = split_equals.join("=")
            if unparsed_params.is_a?(String)
              options = unparsed_params.as(String).split(",").map(&.strip)
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
      end
      return temp_array
    end

    #
    # E.g. Passwords
    #
    def uninteractive_params : Array(SnippetPasswordParam)
      temp_array = [] of SnippetPasswordParam
      real_command.scan(/#password\{\[(.+?)\]\}/) do |m|
        full = m[1].as(String)
        options = full.split(",")
        id = options.shift
        length = UInt8.new(16)
        if options.size > 0
          length = options.shift.to_u32 || UInt8.new(16)
        end
        temp_array << SnippetPasswordParam.new(id, length, full)
      end
      temp_array
    end

    def has_params
      interactive_params.size > 0 || uninteractive_params.size > 0
    end

    def preview_command
      # TODO: syntax highlight and display preview command
      unless has_params()
        return real_command
      end

      temp_command = real_command
      interactive_params.each do |param|
        if param.type == "select"
          temp_command = temp_command.gsub("#select{[#{param.full}]}") { "<#{param.name}>".colorize(:green) }
          temp_command = temp_command.gsub("#select{[#{param.name}]}") { "<#{param.name}>".colorize(:green) }
        else
          temp_command = temp_command.gsub("\#{[#{param.full}]}") { "<#{param.name}>".colorize(:green) }
          temp_command = temp_command.gsub("\#{[#{param.name}]}") { "<#{param.name}>".colorize(:green) }
        end
      end

      uninteractive_params.each do |param|
        temp_command = temp_command.gsub("#password{[#{param.full}]}") { "<PW:#{param.id}>".colorize(:green) }
        temp_command = temp_command.gsub("#password{[#{param.id}]}") { "<PW:#{param.id}>".colorize(:green) }
      end
      temp_command
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
        tags.join(",") || ""
      else
        ""
      end
    end
  end
end
