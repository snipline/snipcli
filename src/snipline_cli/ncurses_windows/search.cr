module SniplineCli::NCursesWindows
  class Search
    property window
    property search_text : String = ""

    def initialize(header_footer_height)
      @window = NCurses::Window.new(
        header_footer_height,
        NCurses.width,
        1,
        0
      )
      @window.set_color 2
      LibNCurses.wprintw(@window, "%s", " Search:")
      LibNCurses.wmove(@window, 0, 9 + search_text.size)
      @window.refresh
    end

    def write(char)
      @window.set_color 2
      @search_text = String.build do |str|
        str << @search_text
        str << char.to_s
      end
      LibNCurses.wmove(@window, 0, 9 + @search_text.size)
      @window.clear
      LibNCurses.wprintw(@window, "%s", " Search: #{@search_text}")
      LibNCurses.wmove(@window, 0, 9 + @search_text.size)
      @window.refresh
    end

    def delete
      @search_text = @search_text.rchop
      LibNCurses.wmove(@window, 0, 9 + @search_text.size)
      @window.clear
      LibNCurses.wprintw(@window, "%s", " Search: #{@search_text}")
      LibNCurses.wmove(@window, 0, 9 + @search_text.size)
      @window.refresh
    end
  end
end
