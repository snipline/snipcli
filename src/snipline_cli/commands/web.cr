require "toml"
require "../config/config"
require "kemal"
require "file"
require "../services/file_storage"
require "../services/log"
require "../services/load_snippets"
require "../models/snippet"

module SniplineCli
  class Command < Admiral::Command
    class Web < Admiral::Command
      define_help description: "Serve a web based interface for managing nippets"
      define_flag port : Int32, default: 9876_i32, long: port, short: p, required: true
      define_flag bind : String, default: "localhost", long: bind, short: b, required: true

      def run
        config = SniplineCli::Config.new
        log = SniplineCli::Services::Log.new
        # add_context_storage_type([] of SniplineCli::Snippet)
        get "/" do |env|
          # env.set "snippets", snippets
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
        Kemal.config.env = ENV["LOG_LEVEL"] == "WARN" ? "production" : "development"
        Kemal.config.host_binding = flags.bind
        Kemal.config.port = flags.port
        Kemal.run
      end
    end

    register_sub_command :web, Web
  end
end
