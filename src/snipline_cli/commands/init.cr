require "toml"

module SniplineCli
  class Command < Admiral::Command

    # The command to initialize Snipline CLI without an active Snipline account.
    #
    # This command generates a config file in the requested location.
    # By default this location is ~/.config/snipline/config.toml
    class Init < Admiral::Command
      define_help description: "Initialise Snipline CLI without logging in"

      def run
        config = SniplineCli.config
        toml_contents = <<-TOML
        title = "Snipline"

        [api]
        url = ""
        token = ""

        [general]
        file = "#{config.get("general.file")}"
        TOML

        SniplineCli::Services::CreateConfigDirectory.run(SniplineCli.config_file)
        File.write(File.expand_path(SniplineCli.config_file), toml_contents, mode: "w")
        puts "Configuration saved to #{File.expand_path(SniplineCli.config_file).colorize.mode(:bold)}"
        puts "To fetch your snippets run #{"snipline sync".colorize.mode(:bold)}"
      end
    end

    register_sub_command :init, Init
  end
end

