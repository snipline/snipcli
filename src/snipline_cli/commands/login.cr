require "toml"
require "../helpers/expand_path"

module SniplineCli
  class Command < Admiral::Command
    # The command to initialize Snipline CLI _with_ an active Snipline account.
    #
    # This command generates a config file in the requested location.
    # By default this location is ~/.config/snipline/config.toml
    class Login < Admiral::Command
      include SniplineCli::Models
      include SniplineCli::Helpers
      define_help description: "Log-in into your Snipline account"

      def run
        config = SniplineCli.config
        puts "What's your Snipline email account?".colorize.mode(:bold)
        puts "Register at #{"https://account.snipline.io/register".colorize.mode(:underline)} if you don't have an account."
				Log.debug { "Test debug" }
        print "Email:"
        email = gets
        # spawn do
        #   Crest.post(
        #     "#{config.get("api.url")}/sessions",
        #     form: {:email => email}
        #   )
        # end
        print "Enter your Snipline Account password:"
        # password = gets
				password = STDIN.noecho &.gets.try &.chomp
				password = password.as?(String) || ""

				Log.debug {

					password_length = password.size
					hidden_password = password.chars.map_with_index { |c, i|
						if i == 0 || i == (password_length - 1)
							c
						else
							'*'
						end
					}.to_s

					"password: #{hidden_password}"
				}
        if password.empty?
          puts "Password not entered. Please try again."
          return
        end
        puts ""
        puts "One moment..."
        begin
          Crest.post(
            "#{config.get("api.url")}/v2/sessions",
            form: {
              :email     => email,
              :password  => password
            }
          ) do |response|
            Log.debug { "response body" }
            json_string = response.body_io.gets_to_end
            Log.debug { json_string.inspect }
            token = Token.from_json(json_string)
            toml_contents = <<-TOML
            title = "Snipline"

            [api]
            url = "#{config.get("api.url")}"
            token = "#{token.jwt}"

            [general]
            db = "#{config.get("general.db")}"
            TOML

            CreateConfigDirectory.run(SniplineCli.config_file)
            File.write(expand_path(SniplineCli.config_file), toml_contents, mode: "w")
            puts "Configuration saved to #{expand_path(SniplineCli.config_file).colorize.mode(:bold)}"
            puts "To fetch your snippets run #{"snipcli sync".colorize.mode(:bold)}"
          end
        rescue ex : Crest::NotFound
          puts "404 Not Found :("
        rescue ex : Crest::InternalServerError
          puts "Internal server error"
        rescue ex : Crest::Forbidden
          puts "Incorrect password"
				rescue
					puts "Unknown error"
        end
      end
    end

    register_sub_command :login, Login
  end
end
