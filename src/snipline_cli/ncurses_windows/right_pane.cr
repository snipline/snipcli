module SniplineCli::NCursesWindows
  class RightPane
    property window
    property border
    property left
    property right
    property documentation_formatter : SniplineCli::Services::DocumentationFormatter

    def initialize(header_footer_height, @left : Int32, @right : Int32)
      @border = NCurses::Window.new(
        NCurses.height - (header_footer_height * 2),
        @right,
        header_footer_height,
        @left
      )
      @window = NCurses::Window.new(
        @border.height - 2,
        @right - 3,
        3,
        @left + 2
      )
      @documentation_formatter = SniplineCli::Services::DocumentationFormatter.new(@window)
      @window.set_color 2
      @border.set_color 2
      LibNCurses.box(@border, 0, 0)
      @border.refresh
      @window.refresh
      @window
    end

    def display(snippet : SniplineCli::Models::SnippetSchema | Nil)
      @window.clear
      if snippet
        LibNCurses.wattr_off(@window, NCurses::Attribute::Bold, nil)
        LibNCurses.wattr_on(@window, NCurses::Attribute::Bold, nil)
        LibNCurses.wprintw(@window, "%s", "Command\n")
        LibNCurses.wattr_off(@window, NCurses::Attribute::Bold, nil)
        print_snippet(snippet.preview_command, @window.width)
        LibNCurses.wprintw(@window, "%s", "\n\n")
        LibNCurses.wattr_on(@window, NCurses::Attribute::Bold, nil)
        LibNCurses.wprintw(@window, "%s", "Documentation\n")
        LibNCurses.wattr_off(@window, NCurses::Attribute::Bold, nil)
        @documentation_formatter.to_ncurses(snippet.documentation)
      else
        @window.print("No results found")
      end
      @window.refresh
    end

    def print_snippet(command, width)
      number_of_extra_lines = command.as(String).each_line(true).size - 3
      command.as(String).each_line(true).first(3).each do |line|
        LibNCurses.wprintw(@window, "%s\n", line)
      end
      if number_of_extra_lines > 0
        LibNCurses.wattr_on(@window, NCurses::Attribute::Underline, nil)
        LibNCurses.wprintw(@window, "%s", "#{number_of_extra_lines} more lines")
        LibNCurses.wattr_off(@window, NCurses::Attribute::Underline, nil)
      end
    end
  end
end
