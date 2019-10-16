module SniplineCli::NCursesWindows
  class MultiParamPane
    property window
    property border
    property command_builder
    property param
    property entered_text : String = ""
    property selected_index : UInt32 = 0

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
      @selected_index = 0
      LibNCurses.curs_set(0)
      display_options

      # LibNCurses.wmove(@window, 1, @entered_text.size)
      @window.get_char do |ch|
        break unless ch.is_a?(Char)
        codepoint = ch.ord
        if codepoint == 10
          # choose param
          break
        elsif codepoint == 75 # S+k - up
          select_higher
        elsif codepoint == 74
          select_lower
        else # 	# write(ch.ord.to_s)
          # write(ch)
        end
      end
      @window.refresh
      @command_builder = @command_builder.gsub("\#select{[#{param.full}]}") { @param.options[@selected_index] }
      @command_builder = @command_builder.gsub("\#{[#select{param.name}]}") { @param.options[@selected_index] }
      @command_builder
    end

    def select_higher
      unless @selected_index == 0
        @selected_index = @selected_index - 1
        display_options
      end
    end

    def select_lower
      unless @selected_index == (@param.options.size - 1)
        @selected_index = @selected_index + 1
        display_options
      end
    end

    def display_options
      @window.clear
      @window.set_color 2
      @window.print("Choose #{param.name}:\n")
      param.options.each_with_index do |option, index|
        if index == @selected_index
          @window.set_color 4
        else
          @window.set_color 2
        end
        @window.print("#{option}\n")
      end
      @window.refresh
    end
  end
end
