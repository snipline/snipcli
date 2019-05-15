require "toml"
require "../config/config"
require "kemal"
require "file"

module SniplineCli
  class Command < Admiral::Command
    class Web < Admiral::Command
      define_help description: "Serve a web based interface for managing nippets"

      def run
        get "/" do
          render "src/snipline_cli/templates/index.ecr", "src/snipline_cli/templates/layout.ecr"
        end
        Kemal.run
      end
    end

    register_sub_command :web, Web
  end
end
