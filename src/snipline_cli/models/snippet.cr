module SniplineCli::Models
  class Snippet < Crecto::Model
    set_created_at_field :inserted_at

    schema "snippets" do
      field :local_id, Int32, primary_key: true
      field :cloud_id, String
      field :name, String
      field :real_command, String
      field :documentation, String
      field :tags, String
      field :snippet_alias, String
      field :is_pinned, Bool
      field :is_synced, Bool
    end

    validate_required [:name, :real_command]
    validate_length :name, min: 1
    validate_length :real_command, min: 1
    unique_constraint :snippet_alias
    unique_constraint :name

    #
    # Params such as variables or select that require input from the user
    #
    def interactive_params : Array(SnippetParam)
      temp_array = [] of SnippetParam

      real_command.as(String).scan(/#(select)?\{\[(.+?)\]\}/) do |m|
        param_type = (m[1]?) ? m[1] : "variable"
        if temp_array.count { |param| param.name == m[2] && param_type == param.type } == 0
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
      temp_array
    end

    #
    # E.g. Passwords
    #
    def uninteractive_params : Array(SnippetPasswordParam)
      temp_array = [] of SnippetPasswordParam
      real_command.as(String).scan(/#password\{\[(.+?)\]\}/) do |m|
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
      unless has_params()
        return real_command
      end

      temp_command = real_command
      interactive_params.each do |param|
        if param.type == "select"
          temp_command = temp_command.as(String).gsub("#select{[#{param.full}]}") { "<#{param.name}>" }
          temp_command = temp_command.as(String).gsub("#select{[#{param.name}]}") { "<#{param.name}>" }
        else
          temp_command = temp_command.as(String).gsub("\#{[#{param.full}]}") { "<#{param.name}>" }
          temp_command = temp_command.as(String).gsub("\#{[#{param.name}]}") { "<#{param.name}>" }
        end
      end

      uninteractive_params.each do |param|
        temp_command = temp_command.as(String).gsub("#password{[#{param.full}]}") { "<PW:#{param.id}>" }
        temp_command = temp_command.as(String).gsub("#password{[#{param.id}]}") { "<PW:#{param.id}>" }
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
