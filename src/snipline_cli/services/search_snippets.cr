require "json"

module SniplineCli::Services
  # For saving Snippets locally.
  class SearchSnippets
    property snippets

    # Takes an array of snippets and saves them to the `snippet.json` file.
    def initialize(@snippets = [] of Snippet)
    end

    def search(search_term)
      results = @snippets.select { |i|
        i.name != ""
      }
      unless search_term.empty?
        lowered_search_term = search_term.downcase
        results = results.select do |i|
					snippet_has_search_term(i, lowered_search_term)
        end
      end

      sort_results(results)
    end

		def snippet_has_search_term(i, lowered_search_term)
			if i.tags.is_a?(String) && i.tags.as(String).split(",").includes?(lowered_search_term) 
				true
			elsif i.name.as(String).downcase.includes?(lowered_search_term)
				true
			elsif i.real_command.as(String).downcase.includes?(lowered_search_term) 
				true
			elsif i.snippet_alias.is_a?(String) && i.snippet_alias.as(String).downcase.includes?(lowered_search_term)
				true
			else
				false
			end
		end

    def sort_results(snippets)
      snippets.sort { |snippet_a, snippet_b|
        if snippet_a.is_pinned && snippet_b.is_pinned
          snippet_a.name.as(String) <=> snippet_b.name.as(String)
        elsif snippet_a.is_pinned
          -1
        elsif snippet_b.is_pinned
          1
        else
          snippet_a.name.as(String) <=> snippet_b.name.as(String)
        end
      }
    end
  end
end
