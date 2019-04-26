require "json"
require "colorize"
require "file_utils"
require "toml"
require "../config/config"

module SniplineCli
    class Command < Admiral::Command
		class Sync < Admiral::Command
            define_help description: "For syncing snippets from Snipline"

			def run
				puts "Syncing snippets..."
                config = SniplineCli::Config.new
                Crest.get(
                    "#{config.get("api.url")}/snippets",
                    headers: {
                        # "Accept" => "application/vnd.api+json",
                        "Authorization" => "Bearer #{config.get("api.token")}",
                    }) do |resp|
                        # Save the response JSON into a file without the data wrapper
                        snippets = SnippetDataWrapper.from_json(resp.body).data.to_json
                        unless File.directory?(File.expand_path("~/.config/snipline"))
                            puts "Creating ~/.config/snipline directory"
                            Dir.mkdir(File.expand_path("~/.config/snipline"))
                        end
                        File.write(File.expand_path("~/.config/snipline/snippets.json"), snippets, mode: "w")
                        unless File.writable?(File.expand_path("~/.config/snipline/snippets.json"))
                            puts "Sync Failed: File not writable (~/.config/snipline/snippets.json)"
                        end
                    end
            end
		end
        register_sub_command :sync, Sync
    end
end
