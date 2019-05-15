require "toml"
require "../config/config"
require "kemal"
require "file"
require "../services/file_storage"

module SniplineCli
  class Command < Admiral::Command
    class Web < Admiral::Command
      define_help description: "Serve a web based interface for managing nippets"

      def run
        get "/" do
          render "src/snipline_cli/templates/index.ecr", "src/snipline_cli/templates/layout.ecr"
        end
        get "/app.css" do |env|
          env.response.content_type = "text/css"
          file = Services::FileStorage.get("css/app.css")
          file.gets_to_end
        end
        get "/app.js" do |env|
          env.response.content_type = "text/javascript"
          file = Services::FileStorage.get("js/app.js")
          file.gets_to_end
        end
        Kemal.run
      end
    end

    register_sub_command :web, Web
  end
end
