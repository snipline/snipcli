# TODO: Write documentation for `SniplineCli`
require "admiral"
require "crest"

module SniplineCli
  VERSION = "0.1.0"

	class Command < Admiral::Command
		define_version "0.1.0"
		class Login < Admiral::Command
			define_help description: "For logging into your Snipline account"
			def run
				puts "What's your Snipline email account?"
				email = gets
				spawn do 
					Crest.post(
						"http://localhost:4001/api/sessions",
						form: {:email => email}
					)
				end
				puts "Thanks, we're sending you a verification code..."
				sleep 1
				puts "Please enter the verification code we sent you:"
				verification_code = gets
				puts "Thanks!"
				puts "Retrieving your long-life token..."
				Crest.get(
					"http://localhost:4001/api/tokens/create",
					params: {:id => email, :token => verification_code}
				) do |response|
					puts typeof(response.body)
					puts response.body.inspect
				end
			end
		end

		class Search < Admiral::Command
			define_help description: "For searching your snippets"
			def run
				puts "Searching..."
			end
		end

		register_sub_command :login, Login
		register_sub_command :search, Search

		# def run
		# 	puts "help"
		# end
	end
end

SniplineCli::Command.run
