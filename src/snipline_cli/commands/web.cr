require "toml"
require "kemal"
require "file"

module SniplineCli
  class Command < Admiral::Command
    # The command to start the web version of Snipline CLI
    #
    # ```bash
    # snipcli web -b 0.0.0.0 -p 3000
    # ```
    #
    # The web version allows you to view snippets in a friendly GUI.
    #
    # In the future this command will allow you to create, edit, and delete snippets.
    class Web < Admiral::Command
      define_help description: "Serve a web based interface for managing nippets"
      define_flag port : Int32, default: 9876_i32, long: port, short: p, required: true
      define_flag bind : String, default: "localhost", long: bind, short: b, required: true

      def run
        # add_context_storage_type([] of SniplineCli::Snippet)
        get "/" do
          # env.set "snippets", snippets
          render "src/snipline_cli/templates/index.ecr", "src/snipline_cli/templates/layout.ecr"
        end

        get "/snippets/new" do
          # ameba:disable Lint/UselessAssign
          sync_to_cloud = false
          # ameba:disable Lint/UselessAssign
          snippet_attributes = SnippetAttribute.new(
            name: "",
            real_command: "",
            documentation: "",
            is_pinned: false,
            snippet_alias: "",
            tags: [] of String
          )
          error : String? = nil
          success : String? = nil
          snippet_errors : SnippetErrorResponse? = nil
          render "src/snipline_cli/templates/snippets/new.ecr", "src/snipline_cli/templates/layout.ecr"
        end

        post "/snippets" do |env|
          snippet_params = env.params.body
          sync_to_cloud = snippet_params.fetch_all("sync").includes?("true")
          snippet_attributes = SnippetAttribute.new(
            name: snippet_params["name"],
            real_command: snippet_params["real_command"],
            documentation: snippet_params["documentation"],
            is_pinned: (snippet_params.fetch_all("is_pinned").includes?("true")) ? true : false,
            snippet_alias: snippet_params["alias"],
            tags: [] of String
          )

          error : String? = nil
          success : String? = nil
          snippet_errors : SnippetErrorResponse? = nil

          begin
            snippet = if sync_to_cloud
                        SniplineCli::Services::SyncSnippetToSnipline.handle(snippet_attributes)
                      else
                        Snippet.new(id: nil, type: "snippet", attributes: snippet_attributes)
                      end
            unless snippet.is_a?(Snippet)
              SniplineCli::Services::AppendSnippetToLocalStorage.handle(snippet)
            end
            # ameba:disable Lint/UselessAssign
            success = "Snippet saved to Snipline"
            # ameba:disable Lint/UselessAssign
            snippet_attributes = SnippetAttribute.new(
              name: "",
              real_command: "",
              documentation: "",
              is_pinned: false,
              snippet_alias: "",
              tags: [] of String
            )
          rescue ex : Crest::UnprocessableEntity
            # ameba:disable Lint/UselessAssign
            error = "Invalid data"
            # ameba:disable Lint/UselessAssign
            snippet_errors = SnippetErrorResponse.from_json(ex.response.body)
            # ameba:disable Lint/UselessAssign
            success = nil
          rescue ex : Crest::NotFound
            # ameba:disable Lint/UselessAssign
            error = "404 API URL not found"
            # ameba:disable Lint/UselessAssign
            success = nil
          rescue ex : Crest::InternalServerError
            # ameba:disable Lint/UselessAssign
            error = "API Internal Server Error"
            # ameba:disable Lint/UselessAssign
            success = nil
          rescue
            # ameba:disable Lint/UselessAssign
            error = "Connection Refused"
            # ameba:disable Lint/UselessAssign
            success = nil
          end
          # env.set "snippets", snippets
          render "src/snipline_cli/templates/snippets/new.ecr", "src/snipline_cli/templates/layout.ecr"
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
