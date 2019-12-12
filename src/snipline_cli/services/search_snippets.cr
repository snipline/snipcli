require "json"
require "fuzzy_match"

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

      sort_results(results, search_term)
    end

    def snippet_has_search_term(i, lowered_search_term)
      if i.tags.is_a?(String) && i.tags.as(String).split(",").includes?(lowered_search_term)
        true
      elsif FuzzyMatch::Simple.new(lowered_search_term, i.name.as(String).downcase).matches?
        true
      elsif i.real_command.as(String).downcase.includes?(lowered_search_term)
        true
      elsif i.snippet_alias.is_a?(String) && i.snippet_alias.as(String).downcase.includes?(lowered_search_term)
        true
      else
        false
      end
    end

    def sort_results(snippets, search_term)
      snippets.sort { |snippet_a, snippet_b|
        if snippet_a.is_pinned && snippet_b.is_pinned
          FuzzyMatch::Full.new(search_term, snippet_a.name.as(String)).score <=> FuzzyMatch::Full.new(search_term, snippet_b.name.as(String)).score
        elsif snippet_a.is_pinned
          -1
        elsif snippet_b.is_pinned
          1
        else
          FuzzyMatch::Full.new(search_term, snippet_a.name.as(String)).score <=> FuzzyMatch::Full.new(search_term, snippet_b.name.as(String)).score
        end
      }
    end
  end
end
