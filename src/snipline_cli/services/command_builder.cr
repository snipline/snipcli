module SniplineCli
  module Services
    class CommandBuilder
      def self.run(snippet : Snippet) : String
        unless snippet.has_params
          return snippet.real_command
        end

        command_builder = snippet.real_command
        snippet.interactive_params.each_with_index do |param, index|
          case param.type
          when "select"
            puts "Choose number for #{param.name}:"
            param.options.each_with_index do |option, option_index|
              puts "  ##{option_index + 1} - #{option}"
            end
            # todo: list options and let user select via number
            if user_param_input = gets
              if user_param_input = user_param_input.to_u32
                user_param_input = user_param_input - 1
                if param.options.size > user_param_input
                  command_builder = command_builder.gsub("#select{[#{param.full}]}") { param.options[user_param_input] }
                  command_builder = command_builder.gsub("#select{[#{param.name}]}") { param.options[user_param_input] }
                end
              end
            end
          else
            puts "Enter #{param.name}:"
            if param.default_value != ""
              puts "Leave blank for default (#{param.default_value})"
            end
            if user_param_input = gets
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
