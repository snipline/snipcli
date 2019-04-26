require "json"
require "colorize"
require "file_utils"
require "toml"
require "../gateways/command_builder"
require "../config/config"
require "../models/snippet"

module SniplineCli
    class Command < Admiral::Command
		class Search < Admiral::Command
            define_help description: "For searching your snippets"
            define_argument search_term : String,
                description: "The term to search for",
                default: nil,
                required: false
            define_flag limit : UInt32, default: 5_u32, long: limit

            property results

			def run
                puts "Searching...#{arguments.search_term.as(String)}\n"

                unless File.readable?(File.expand_path("~/.config/snipline/snippets.json"))
                    puts "Could not read ~/.config/snipline/snippets.json"
                    puts "Run #{"snipline-cli sync".colorize(:green)} first"
                    return
                end

                snippets = [] of Snippet

                File.open(File.expand_path("~/.config/snipline/snippets.json")) do |file|
                    snippets = Array(Snippet).from_json(file)
                end

                if arguments.search_term.is_a?(String)
                    lowered_search_term = arguments.search_term.as(String).downcase
                    snippets.select! { |i| 
                        i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || i.tags.includes?(lowered_search_term)
                    }
                end

                results = snippets.sort { |snippet_a, snippet_b| 
                    if snippet_a.is_pinned && snippet_b.is_pinned
                        snippet_a.name <=> snippet_b.name
                    elsif snippet_a.is_pinned
                        -1
                    elsif snippet_b.is_pinned
                        1
                    else
                        snippet_a.name <=> snippet_b.name
                    end
                }.first(flags.limit)
                    
                results.each_with_index { |snippet, index|
                    puts "##{index + 1} #{snippet.name.colorize(:green)} #{snippet.is_pinned ? "⭐️" : ""}#{(snippet.tags.size > 0) ? "[" + snippet.tags.join(",") + "]" : ""}\n#{snippet.preview_command}\n\n"
                }

                puts "\nChoose a snippet"
                chosen_snippet_index = gets

                if chosen_snippet_index
                    if chosen_snippet_index.to_i?
                        chosen_snippet_index = (chosen_snippet_index.to_u32 - 1)

                        if results.size > chosen_snippet_index && chosen_snippet_index >= 0
                            output = SniplineCli::Gateways::CommandBuilder.run(results[chosen_snippet_index])
                            puts "Do you want to run '#{output.colorize(:green)}' in #{FileUtils.pwd.colorize(:green)}? (y/N)"
                            if answer = gets
                                if answer == "y" || answer == "yes"
                                    system "#{output}"
                                    # system %(pbcopy < "#{output}")
                                end
                            end
                        else
                            p "Snippet does not exist"
                        end
                    else
                        puts "You did not select a snippet."
                    end
                end
            end
        end

        register_sub_command :search, Search

    end
end