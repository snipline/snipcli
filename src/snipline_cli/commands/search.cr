require "json"
require "colorize"
require "file_utils"
require "toml"

module SniplineCli
  class Command < Admiral::Command
    # The command to search your snippets.
    #
    # You can search snippets quickly by using
    #
    # ```bash
    # snipcli search <searchterm>
    # ```
    #
    # You can specify a field to search or the result limit.
    #
    # ```bash
    # snipcli search <searchterm> --field=tags --limit=10
    # ```
    class Search < Admiral::Command
      define_help description: "For searching your snippets"
      define_argument search_term : String,
        description: "The term to search for",
        default: nil,
        required: false
      define_flag limit : UInt32, default: 500_u32, long: limit
      define_flag field : String,
        description: "The field to search (alias|documentation|name|tags)",
        default: nil,
        required: false

      property results

      def run
        search_term : String = arguments.search_term || ""

        begin
          snippets = if search_term.empty?
                       query = Crecto::Repo::Query.order_by("is_pinned ASC").order_by("name ASC").limit(flags.limit.to_i)
                       Repo.all(Snippet, query)
                     else
                       lowered_search_term = search_term.downcase
                       if flags.field != nil && !["alias", "documentation", "name", "tags"].includes?(flags.field.not_nil!)
                         puts "The search field entered does not exist."
                         return
                       end
                       query = Crecto::Repo::Query.new
                       query = if flags.field
                                 # query.where("snippets.#{flags.field.not_nil!.downcase} = ?", lowered_search_term)
                                 query
                               else
                                 wildcard_query = "%#{lowered_search_term}%"
                                 query.where("snippets.name LIKE ?", wildcard_query).or_where("snippets.real_command LIKE ?", wildcard_query).or_where("snippets.snippet_alias LIKE ?", wildcard_query).or_where("snippets.tags LIKE ?", wildcard_query)
                               end
                       Repo.all(Snippet, query)
                       # snippets.select! { |i|
                       #   if field = flags.field
                       #     i.value_for_attribute(field).downcase.includes?(lowered_search_term)
                       #   else
                       # 		if !i.tags.nil?
                       # 			i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || i.tags.as(Array(String)).includes?(lowered_search_term)
                       # 		else
                       # 			i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term)
                       # 		end
                       #   end
                       # }
                     end

          # results = sort_results(snippets, flags.limit)

          # unless results.size > 0
          #   puts "No results found."
          #   exit(0)
          # end
        rescue ex
          puts "Error: #{ex.inspect}".colorize(:red)
          abort
        end

        DisplayResults.new(snippets)
      end

      def sort_results(snippets, limit)
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
        }.first(limit)
      end
    end

    register_sub_command :search, Search
  end
end
