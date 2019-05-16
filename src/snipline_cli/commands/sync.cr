require "json"
require "colorize"
require "file_utils"
require "toml"

module SniplineCli
  class Command < Admiral::Command
    class Sync < Admiral::Command
      define_help description: "For syncing snippets from Snipline"

      def run
        puts "Syncing snippets..."
        config = SniplineCli.config
        Crest.get(
          "#{config.get("api.url")}/snippets",
          headers: {
            # "Accept" => "application/vnd.api+json",
            "Authorization" => "Bearer #{config.get("api.token")}",
          }) do |resp|
          # Save the response JSON into a file without the data wrapper
          snippets = SnippetDataWrapper.from_json(resp.body_io.gets_to_end).data.to_json
          directory = File.dirname(File.expand_path(config.get("general.file")))
          unless File.directory?(directory)
            puts "Creating #{directory} directory"
            Dir.mkdir(File.expand_path(directory))
          end
          File.write(File.expand_path(config.get("general.file")), snippets, mode: "w")
          unless File.writable?(File.expand_path(config.get("general.file")))
            puts "Sync Failed: File not writable (#{config.get("general.file")})"
          end
        end
      end
    end

    register_sub_command :sync, Sync
  end
end
