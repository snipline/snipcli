module SniplineCli::NCursesWindows
  class Footer
    property window

    def initialize(header_footer_height)
      @window = NCurses::Window.new(
        header_footer_height,
        NCurses.width,
        NCurses.height - header_footer_height,
        0
      )
      @window.set_color 1
      LibNCurses.wprintw(@window, "%s", " <C-c> Quit | <S-j> Down | <S-k> Up | <CR> - Copy | <S-r> Run\n")
      LibNCurses.mvwchgat(@window, 0, 0, -1, NCurses::Attribute::Reverse, 2, nil)
      @window.refresh
    end
  end
end
