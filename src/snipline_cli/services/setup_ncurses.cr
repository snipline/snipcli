module SniplineCli::Services
  class Setup
    def initialize
      NCurses.start
      NCurses.cbreak
      NCurses.no_echo
      NCurses.keypad true

      unless NCurses.has_colors?
        NCurses.end
        exit(1)
      end
      NCurses.start_color

      NCurses.init_color_pair(1, NCurses::Color::White, NCurses::Color::Green)
      NCurses.init_color_pair(2, NCurses::Color::Green, NCurses::Color::Black)
      NCurses.init_color_pair(3, NCurses::Color::Green, NCurses::Color::Black)
      NCurses.init_color_pair(4, NCurses::Color::Black, NCurses::Color::Green)

      # This turns off the blinking cursor
      LibNCurses.curs_set(1)
    end
  end
end
