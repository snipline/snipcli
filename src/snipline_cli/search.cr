require "json"
require "colorize"
require "toml"
require "./gateways/command_builder"

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
				puts "Searching...\n"
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
                        if chosen_snippet_index = gets
                            chosen_snippet_index = (chosen_snippet_index.to_u32 - 1)

                            if results.size > chosen_snippet_index
                                output = SniplineCli::Gateways::CommandBuilder.run(results[chosen_snippet_index])
                                puts "Do you want to run '#{output.colorize(:green)}'? (y/N)"
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
                            p "Action cancelled"
                        end
                end
            end
            
            def run_command(cmd, args)
                stdout = IO::Memory.new
                stderr = IO::Memory.new
                status = Process.run(cmd, args: args, output: stdout, error: stderr)
                if status.success?
                    {status.exit_code, stdout.to_s}
                else
                    {status.exit_code, stderr.to_s}
                end
            end
		end
        register_sub_command :search, Search

    end
end