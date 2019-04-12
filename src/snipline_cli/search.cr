require "json"
require "colorize"
require "toml"

module SniplineCli
    class Command < Admiral::Command
		class Search < Admiral::Command
            define_help description: "For searching your snippets"
            define_argument search_term : String,
                description: "The term to search for",
                default: nil,
                required: false
            define_flag limit : UInt32, default: 5_u32, long: limit

			def run
				puts "Searching..."
				config_file = File.read(File.expand_path("~/.config/snipline/config.toml"))
                toml = TOML.parse(config_file)
                api = toml["api"].as(Hash)
                Crest.get(
                    "#{api["url"].as(String)}/snippets",
                    headers: {
                        # "Accept" => "application/vnd.api+json",
                        "Authorization" => "Bearer #{api["token"].as(String)}",
                    }) do |resp|
                        # puts response.body.inspect
                        snippets = SnippetDataWrapper.from_json(resp.body).data
                        if arguments.is_a?(String)
                            snippets.select! { |i| 
                                lowered_search_term = arguments.search_term.as(String).downcase
                                i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || i.tags.includes?(lowered_search_term)
                            }
                        end
                        snippets.sort { |snippet_a, snippet_b| 
                            if snippet_a.is_pinned && snippet_b.is_pinned
                                snippet_a.name <=> snippet_b.name
                            elsif snippet_a.is_pinned
                                -1
                            elsif snippet_b.is_pinned
                                1
                            else
                                snippet_a.name <=> snippet_b.name
                            end
                        }.first(flags.limit).each_with_index { |snippet, index|
                            puts "##{index + 1} #{snippet.name.colorize(:green)} #{snippet.is_pinned ? "⭐️" : ""}#{(snippet.tags.size > 0) ? "[" + snippet.tags.join(",") + "]" : ""}\n#{snippet.preview_command}\n\n"
                        }
                        puts "\nChoose a snippet"
                        chosen_snippet_index = gets
                end
			end
		end
		register_sub_command :search, Search
    end
end