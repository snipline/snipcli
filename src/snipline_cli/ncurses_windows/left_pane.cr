module SniplineCli::NCursesWindows
  class LeftPane
    property window
    property border
    property left
    property right
    property selected_index = 0
    property searcher : SearchSnippets
    property results : Array(SnippetSchema)
    property snippets : Array(SnippetSchema)

    def initialize(header_footer_height, @left : Int32, @right : Int32, @snippets = [] of SnippetSchema)
      @results = @snippets
      @searcher = SearchSnippets.new(@snippets)

      @border = NCurses::Window.new(
        NCurses.height - (header_footer_height * 2),
        @right,
        header_footer_height,
        @left
      )
      # @window = NCurses::Window.new(
      # 	NCurses.height - (header_footer_height * 2) - 2,
      # 	@right - 4,
      # 	header_footer_height + 1,
      # 	@left + 2
      # )
      # @border.refresh
      @window = NCurses::Window.new(
        @border.height - 2,
        @right - 3,
        3,
        @left + 2
      )
      @window.set_color 2
      @border.set_color 2
      LibNCurses.box(@border, 0, 0)
      # @window.print("Hello\n")
      # @window.print(@right.to_s + "\n")
      # @window.print(NCurses.width.to_s + "\n")
      @border.refresh
      @window.refresh
      @window
    end

    def filter(search_text : String)
      @window.clear
      search_text = search_text.downcase

      @results = searcher.search(search_text)
      @results = @results[0..(@window.height - 1)]
      if @selected_index > (@results.size - 1)
        @selected_index = [@results.size - 1, 0].max
      end
      @results.each_with_index do |result, index|
        if index == @selected_index
          @window.set_color 4
        else
          @window.set_color 2
        end
        show_snippet_row(result)
      end
      @window.refresh
    end

    def show_snippet_row(result)
      if result.is_pinned
        @window.print("* ")
      end

      if result.snippet_alias.is_a?(String)
        @window.print("[#{result.snippet_alias}] ")
      end

      @window.print(result.name.as(String) + "\n")
    end

    def select_higher
      unless @selected_index == 0
        @selected_index = @selected_index - 1
      end
    end

    def select_lower
      unless @selected_index == (@results.size - 1)
        @selected_index = @selected_index + 1
      end
    end
  end
end
