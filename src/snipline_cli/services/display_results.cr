module SniplineCli::Services
  # For saving Snippets locally.
  class DisplayResults
    property header
    property search
    property left_pane
    property right_pane
    property footer

    # propery main_left
    # propery main_left_border
    # @@footer = NCurses::Window.new

    def initialize(results)
      Setup.new
      header_footer_height = 1
      @header = SniplineCli::NCursesWindows::Header.new(header_footer_height)
      @footer = SniplineCli::NCursesWindows::Footer.new(header_footer_height)
      @left_pane = SniplineCli::NCursesWindows::LeftPane.new(header_footer_height + 1, left: 0, right: (NCurses.width / 2), snippets: results)
      @right_pane = SniplineCli::NCursesWindows::RightPane.new(header_footer_height + 1, left: (NCurses.width / 2), right: (NCurses.width / 2.0).ceil.to_i32)
      @search = SniplineCli::NCursesWindows::Search.new(header_footer_height)
      @left_pane.filter("")
      refresh_right_pane
      @search.window.refresh

      @search.window.get_char do |ch|
        break unless ch.is_a?(Char)
        # @search.write(ch.ord.to_s)
        codepoint = ch.ord
        break if codepoint == 17 # C+q - quit

        if codepoint == 127
          @search.delete
          @left_pane.filter(@search.search_text)
          refresh_right_pane
        elsif codepoint == 75 # S+k - up
          @left_pane.select_higher
          refresh_right_pane
        elsif codepoint == 74 # C+j / S+j - down
          @left_pane.select_lower
          refresh_right_pane
        elsif codepoint == 67 || codepoint == 10 # Shift+c / Enter - copy
          output = build_snippet
          copy_snippet(output)
          break
        elsif codepoint == 69 # Shift+r - run
          edit_snippet
          break
        elsif codepoint == 82 # Shift+r - run
          output = build_snippet
          run_snippet(output)
          break
        else
          @search.write(ch)
          @left_pane.filter(@search.search_text)
          refresh_right_pane
        end
        @left_pane.filter(@search.search_text)
        @search.window.refresh
      end
      NCurses.clear
      NCurses.end
    end

    def refresh_right_pane
      if @left_pane.selected_index < @left_pane.results.size
        @right_pane.display(@left_pane.results[@left_pane.selected_index])
      else
        @right_pane.display(nil)
      end
    end

    def copy_to_clipboard
      output = IO::Memory.new
      Process.run("/bin/sh", {"-c", "uname -s"}, output: output)
      if output.to_s.chomp == "Darwin"
        "pbcopy"
      else
        "xclip -selection c"
      end
    end

    def copy_snippet(output)
      NCurses.clear
      NCurses.end
      system "echo \"#{output}\" | tr -d '\n' | tr -d '\r' | #{copy_to_clipboard}"
      puts "'#{output.chomp.colorize(:green)}' has been copied to your clipboard"
    end

    def run_snippet(output)
      NCurses.clear
      NCurses.end
      puts "Are you sure you want to run '#{output.chomp.colorize(:green)}' in #{FileUtils.pwd.colorize(:green)}? (Y/n)"
      if answer = gets
        unless ["n", "N", "no"].includes?(answer)
          system("#{output}")
        end
      end
    end

    def build_snippet
      NCurses.clear
      NCurses.end
      CommandBuilder.run(@left_pane.results[@left_pane.selected_index], STDIN, STDOUT)
    end

    def edit_snippet
      NCurses.clear
      NCurses.end
      EditSnippet.run(@left_pane.results[@left_pane.selected_index], STDIN, STDOUT)
    end
  end
end
