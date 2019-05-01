require "toml"
require "../config/config"

module SniplineCli
    class Command < Admiral::Command
		class Login < Admiral::Command
			define_help description: "Log-in into your Snipline account"
			def run
                config = SniplineCli::Config.new
				puts "What's your Snipline email account?".colorize.mode(:bold)
                puts "Register at #{"https://account.snipline.io/register".colorize.mode(:underline)} if you don't have an account."
                print "Email:"
				email = gets
				spawn do 
					Crest.post(
						"#{config.get("api.url")}/sessions",
						form: {:email => email}
					)
				end
				puts "Thanks, we're sending you a verification code..."
				sleep 1
                puts "Please enter the verification code that was sent to your email:"
                print "Verification Code:"
                verification_code = gets
                if verification_code.nil? || verification_code.empty?
                    puts "Code not entered. Please try again."
                    return
                end
                puts "One moment..."
                    puts "URL: #{config.get("api.url")}"
                begin
				    Crest.post(
					    "#{config.get("api.url")}/tokens/create",
					    params: {
						    :id => email, 
						    :token => verification_code, 
						    :length => "year"
                        },
                    ) do |response|
                        token = Token.from_json(response.body)
                        toml_contents = <<-TOML
                        title = "Snipline"

                        [api]
                        url = "#{config.get("api.url")}"
                        token = "#{token.jwt}"

                        [general]
                        file = "#{config.get("general.file")}"
                        TOML

                        File.write(File.expand_path("~/.config/snipline/config.toml"), toml_contents, mode: "w")
                        puts "Configuration saved to #{File.expand_path("~/.config/snipline/config.toml").colorize.mode(:bold)}"
                        puts "To fetch your snippets run #{"snipline sync".colorize.mode(:bold)}"
                    end
                rescue ex : Crest::NotFound
                    puts "404 Not Found :("
                    ex.response
                rescue ex : Crest::InternalServerError
                    puts "Internal server error"
                    ex.response
                rescue ex : Crest::Forbidden
                    puts "Incorrect Token"
                    ex.response
                end
			end
		end


		register_sub_command :login, Login
    end
end