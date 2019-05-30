require "toml"

module SniplineCli
  class Command < Admiral::Command

    # The command to initialize Snipline CLI _with_ an active Snipline account.
    #
    # This command generates a config file in the requested location.
    # By default this location is ~/.config/snipline/config.toml
    class Login < Admiral::Command
      define_help description: "Log-in into your Snipline account"

      def run
        config = SniplineCli.config
        log = SniplineCli.log
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
        log.debug("verification_code: #{verification_code}")
        if verification_code.nil? || verification_code.empty?
          puts "Code not entered. Please try again."
          return
        end
        puts "One moment..."
        puts "URL: #{config.get("api.url")}"
        begin
          Crest.post(
            "#{config.get("api.url")}/tokens/create",
            form: {
              :id     => email,
              :token  => verification_code,
              :length => "year",
            }
          ) do |response|
            log.debug("response body")
            json_string = response.body_io.gets_to_end
            log.debug(json_string.inspect)
            token = Token.from_json(json_string)
            toml_contents = <<-TOML
            title = "Snipline"

            [api]
            url = "#{config.get("api.url")}"
            token = "#{token.jwt}"

            [general]
            file = "#{config.get("general.file")}"
            TOML

            SniplineCli::Services::CreateConfigDirectory.run(SniplineCli.config_file)
            File.write(File.expand_path(SniplineCli.config_file), toml_contents, mode: "w")
            puts "Configuration saved to #{File.expand_path(SniplineCli.config_file).colorize.mode(:bold)}"
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
