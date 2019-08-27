require "toml"

module SniplineCli
  class Command < Admiral::Command
    # The command to initialize Snipline CLI without an active Snipline account.
    #
    # This command generates a config file in the requested location.
    # By default this location is ~/.config/snipline/config.toml
    class New < Admiral::Command
      define_help description: "Create a new Snippet"

      def run
        config = SniplineCli.config
        system("#{ENV["EDITOR"]} '~/config/snipline.toml'")
      end
    end

    register_sub_command :new, New
  end
end

