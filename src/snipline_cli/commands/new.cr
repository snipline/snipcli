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
        temp_file = SniplineCli::Services::TempSnippetEditorFile.new
        temp_file.create
        system("#{ENV["EDITOR"]} #{File.expand_path("#{config.get("general.temp_dir")}/temp.toml")}")
        puts temp_file.read.inspect
      end
    end

    register_sub_command :new, New
  end
end
