require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class SearchSnippets
    property snippets

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def initialize(@snippets = [] of SniplineCli::Models::Snippet)
    end

    def search(search_term)
      results = @snippets.select { |i|
        i.name != ""
      }
      unless search_term.empty?
        lowered_search_term = search_term.downcase
        results = results.select do |i|
					if !i.tags.nil?
						i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || i.tags.as(Array(String)).includes?(lowered_search_term) || (i.snippet_alias.is_a?(String) ? i.snippet_alias.as(String).downcase.includes?(lowered_search_term) : false)
					else
						i.name.downcase.includes?(lowered_search_term) || i.real_command.downcase.includes?(lowered_search_term) || (i.snippet_alias.is_a?(String) ? i.snippet_alias.as(String).downcase.includes?(lowered_search_term) : false)
					end
        end
      end

      sort_results(results)
    end

    def sort_results(snippets)
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
      }
    end
  end
end
