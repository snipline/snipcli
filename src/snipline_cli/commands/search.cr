require "json"
require "colorize"
require "file_utils"
require "toml"
require "../services/command_builder"
require "../config/config"
require "../services/log"
require "../services/load_snippets"

module SniplineCli
  class Command < Admiral::Command
    class Search < Admiral::Command
      define_help description: "For searching your snippets"
      define_argument search_term : String,
        description: "The term to search for",
        default: nil,
        required: false
      define_flag limit : UInt32, default: 5_u32, long: limit

      define_flag field : String,
        description: "The field to search (alias|documentation|name|tags)",
        default: nil,
        required: false

      property results

      def run
        config = SniplineCli::Config.new
        log = SniplineCli::Services::Log.new

        search_term : String = arguments.search_term || ""

        snippets = SniplineCli::Services::LoadSnippets.run

        unless search_term.empty?
          lowered_search_term = search_term.downcase
          if flags.field != nil && !["alias", "documentation", "name", "tags"].includes?(flags.field.not_nil!)
            puts "The search field entered does not exist."
            return
          end
          snippets.select! { |i|
            if field = flags.field
              i.value_for_attribute(field).downcase.includes?(lowered_search_term)
            else
              i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || i.tags.includes?(lowered_search_term)
            end
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

        unless results.size > 0
          puts "No results found."
          return
        end

        results.each_with_index { |snippet, index|
          puts "#{(index + 1).to_s.rjust(4)} #{snippet.name.colorize(:green)} #{snippet.is_pinned ? "⭐️" : ""}#{(snippet.tags.size > 0) ? "[" + snippet.tags.join(",") + "]" : ""}".colorize.mode(:bold)
          puts "     #{snippet.preview_command}"
        }

        puts "\nChoose a snippet"
        chosen_snippet_index = gets

        if chosen_snippet_index
          if chosen_snippet_index.to_i?
            chosen_snippet_index = (chosen_snippet_index.to_u32 - 1)

            if results.size > chosen_snippet_index && chosen_snippet_index >= 0
              output = SniplineCli::Services::CommandBuilder.run(results[chosen_snippet_index])
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
