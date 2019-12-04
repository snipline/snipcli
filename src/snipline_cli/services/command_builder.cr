module SniplineCli
  module Services
    # Takes a `Snippet`, asks for users parameter changes, and then returns the output as a string.
    #
    # ```crystal
    # output = SniplineCli::Services::CommandBuilder.run(results[chosen_snippet_index], STDIN, STDOUT)
    # ```
    #
    # User answers can be pre-supplied for testing
    #
    # ```crystal
    # File.tempfile("test") do |io|
    #   response = SniplineCli::Services::CommandBuilder.run(snippet, io, io, ["example input"])
    # end
    # ```
    class CommandBuilder

      def self.run(snippet : Snippet, input, output, user_input = [] of String) : String
        unless snippet.has_params
          return snippet.real_command || ""
        end

        command_builder : String = snippet.real_command || ""
        Setup.new
        snippet.interactive_params.each do |param|
          NCurses.clear
          case param.type
          when "select"
            multi_param_pane = SniplineCli::NCursesWindows::MultiParamPane.new(command_builder, param)
            command_builder = multi_param_pane.run
          else
            param_pane = SniplineCli::NCursesWindows::ParamPane.new(command_builder, param)
            command_builder = param_pane.run
          end
        end

        # ameba:disable Lint/PercentArrays
        password_characters = %w{a b c d e f g h i j k l m n o
          p q r s t u v w x y z A B C D
          E F G H I J K L M N O P Q R S
          T U V W X Y Z 1 2 3 4 5 6 7 8
          9 0 £ * ^ ] [ : ; | ? , .
          ` ~ /}
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

      # Controls output. If IO then shows in the terminal, otherwise hides it (e.g. for testing)
      private def self.print(message, output)
        case output
        when IO
          output.print(message)
          output.flush
        end
      end

      # Handles user input. If an array of is pre-supplied (E.g. for tests) then they are used.
      # Otherwise user is asked to input the variables in the terminal.
      private def self.gets(output, override_input : String | Nil, *args)
        case override_input
        when String
          override_input
        else
          output.gets(*args)
        end
      end

      # Helper method for running through test input
      # Shifts an array if applicable and returns the first element and the remaining array.
      private def self.shift_input(user_input : Array(String) | Nil)
        if user_input && user_input.size > 0
          {user_input.not_nil!.shift, user_input}
        else
          {nil, user_input}
        end
      end
    end
  end
end
