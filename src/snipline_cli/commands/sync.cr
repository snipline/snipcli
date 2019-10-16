require "json"
require "colorize"
require "file_utils"
require "toml"

module SniplineCli
  class Command < Admiral::Command
    # The command to sync your snippets with your active Snipline account.
    #
    # ```bash
    # snipcli sync
    # ```
    class Sync < Admiral::Command
      define_help description: "For syncing snippets from Snipline"

      property snipline_api : (SniplineCli::Services::SniplineApi | SniplineCli::Services::SniplineApiTest) = SniplineCli::Services::SniplineApi.new
      property file : (SniplineCli::Services::StoreSnippets) = SniplineCli::Services::StoreSnippets.new

      def run
        puts "Syncing snippets..."
        @snipline_api.fetch do |body|
          # Save the response JSON into a file without the data wrapper
          snippets = Models::SnippetDataWrapper.from_json(body).data.to_json
          begin
            @file.store(snippets)
          rescue ex
            puts ex.message
          end
        end
      end
    end

    register_sub_command :sync, Sync
  end
end
