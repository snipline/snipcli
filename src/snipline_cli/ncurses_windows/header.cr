module SniplineCli::NCursesWindows
  class Header
    property window

    def initialize(header_footer_height)
      @window = NCurses::Window.new(
        header_footer_height,
        NCurses.width,
        0,
        0
      )
      @window.set_color 1
      LibNCurses.wprintw(@window, "%s", " Snipline CLI\n")
      LibNCurses.mvwchgat(@window, 0, 0, -1, NCurses::Attribute::Reverse, 2, nil)
      @window.refresh
    end
  end
end
