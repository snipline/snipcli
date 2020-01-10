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
        puts "Migrating Database..."
        Migrator.run
        config = SniplineCli.config
        toml_contents = <<-TOML
        title = "Snipline"

        [api]
        url = "#{config.get("api.url")}"
        token = ""

        [general]
        db = "#{config.get("general.db")}"
        file = "#{config.get("general.file")}"
        temp_dir = "#{config.get("general.temp_dir")}"
        TOML

        CreateConfigDirectory.run(SniplineCli.config_file)
        File.write(File.expand_path(SniplineCli.config_file), toml_contents, mode: "w")
        puts "Configuration saved to #{File.expand_path(SniplineCli.config_file).colorize.mode(:bold)}"
        unless File.exists?(File.expand_path(config.get("general.db")))
          File.write(File.expand_path(config.get("general.db")), "", mode: "w")
          puts "Created SQLite file in #{File.expand_path(config.get("general.db")).colorize.mode(:bold)}"
        end
        puts ""
        puts "Run #{"snipcli new".colorize.mode(:bold)} to create your first snippet"
        puts "Search snippets with #{"snipcli search".colorize.mode(:bold)}"
        puts ""
        puts "See documentation for more information #{"https://github.com/snipline/snipcli".colorize.mode(:bold)}"
        puts ""
        puts "Happy Coding!"
      end
    end

    register_sub_command :init, Init
  end
end
