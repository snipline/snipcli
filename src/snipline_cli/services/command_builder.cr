require "readline"
module SniplineCli
  module Services
    class CommandBuilder

      def self.print(message, output)
        case output
        when IO
          output.print(message)
          output.flush
        end
      end

      def self.gets(output, override_input : String | Nil, *args)
        case override_input
        when String
          return override_input
        else
          output.gets(*args)
        end
      end

      def self.shift_input(user_input : Array(String) | Nil)
        if user_input && user_input.size > 0
          {user_input.not_nil!.shift, user_input}
        else
          {nil, user_input}
        end
      end

      def self.run(snippet : Snippet, input, output, user_input = [] of String) : String
        unless snippet.has_params
          return snippet.real_command
        end

        command_builder = snippet.real_command
        snippet.interactive_params.each_with_index do |param, index|
          case param.type
          when "select"
            print("Choose number for #{param.name}:", output)
            param.options.each_with_index do |option, option_index|
              print("  ##{option_index + 1} - #{option}", output)
            end
            # todo: list options and let user select via number
            current_user_input, user_input = shift_input(user_input)
            if user_param_input = gets(output, current_user_input)
              if user_param_input = user_param_input.to_u32
                user_param_input = user_param_input - 1
                if param.options.size > user_param_input
                  command_builder = command_builder.gsub("#select{[#{param.full}]}") { param.options[user_param_input] }
                  command_builder = command_builder.gsub("#select{[#{param.name}]}") { param.options[user_param_input] }
                end
              end
            end
          else
            print("Enter #{param.name}:\n", output)
            if param.default_value != ""
              print("Leave blank for default (#{param.default_value})\n", output)
            end
            current_user_input, user_input = shift_input(user_input)
            if user_param_input = gets(output, current_user_input)
              if user_param_input == ""
                user_param_input = param.default_value
              end
              command_builder = command_builder.gsub("\#{[#{param.full}]}") { user_param_input }
              command_builder = command_builder.gsub("\#{[#{param.name}]}") { user_param_input }
            end
          end
        end
        password_characters = %w{a b c d e f g h i j k l m n o
          p q r s t u v w x y z A B C D
          E F G H I J K L M N O P Q R S
          T U V W X Y Z 1 2 3 4 5 6 7 8
          9 0 £ * ^ ] [ : ; | ? > < , .
          ` ~ / @}
        snippet.uninteractive_params.each do |param|
          # todo: use string builder instead
          generated_password = ""
          param.length.times do
            selected_index = Random::Secure.rand(password_characters.size)
            generated_password += password_characters[selected_index]
          end
          command_builder = command_builder.gsub("#password{[#{param.full}]}") { generated_password }
          command_builder = command_builder.gsub("#password{[#{param.id}]}") { generated_password }
        end
        command_builder
      end
    end
  end
end
