module SniplineCli::NCursesWindows
  class ParamPane
    property window
    property border
    property command_builder
    property param
    property entered_text : String = ""

    def initialize(@command_builder : String, @param : SniplineCli::Models::SnippetParam)
      @border = NCurses::Window.new(
        NCurses.height,
        NCurses.width,
        0,
        0
      )
      # @window = NCurses::Window.new(
      # 	NCurses.height - (header_footer_height * 2) - 2,
      # 	@right - 4,
      # 	header_footer_height + 1,
      # 	@left + 2
      # )
      # @border.refresh
      @window = NCurses::Window.new(
        NCurses.height - 2,
        NCurses.width - 2,
        1,
        1
      )
      @window.set_color 2
      @border.set_color 2
      LibNCurses.box(@border, 0, 0)
      # @window.print(@right.to_s + "\n")
      # @window.print(NCurses.width.to_s + "\n")
      @border.refresh
      @window.refresh
      @window
    end

    def run
      @entered_text = param.default_value
      LibNCurses.curs_set(1)
      @window.print("Enter #{param.name}:\n#{entered_text}")
      LibNCurses.wmove(@window, 1, @entered_text.size)
      @window.get_char do |ch|
        break unless ch.is_a?(Char)
        codepoint = ch.ord
        if codepoint == 127 # backspace
          delete
        elsif codepoint == 10 # enter
          break
        else # 	# write(ch.ord.to_s)
          write(ch)
        end
      end
      @window.refresh
      @command_builder = @command_builder.gsub("\#{[#{param.full}]}") { @entered_text }
      @command_builder = @command_builder.gsub("\#{[#{param.name}]}") { @entered_text }
      @command_builder
    end

    def write(char)
      # @window.set_color 2
      @entered_text = String.build do |str|
        str << @entered_text
        str << char.to_s
      end
      @window.clear
      @window.print("Enter #{param.name}:\n#{@entered_text}")
      # LibNCurses.wprintw(@window, "%s", " Search: #{@entered_text}")
      LibNCurses.wmove(@window, 1, @entered_text.size)
      @window.refresh
    end

    def delete
      @entered_text = @entered_text.rchop
      LibNCurses.wmove(@window, 1, @entered_text.size)
      @window.clear
      LibNCurses.wprintw(@window, "%s", "Enter #{param.name}:\n#{@entered_text}")
      LibNCurses.wmove(@window, 1, @entered_text.size)
      @window.refresh
    end
  end
end
