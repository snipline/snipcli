module SniplineCli::Services
  class DocumentationFormatter
    property window

    def initialize(@window : NCurses::Window | SniplineCli::NCursesWindows::MockWindow)
    end

    def to_ncurses(documentation : Nil)
      @window.print("No documentation found")
    end

    def to_ncurses(documentation : String)
      format_documentation(documentation, @window.width).each do |line|
        @window.print("#{line}")
      end
    end

    def format_documentation(documentation, width)
      formatted_line = String::Builder.new
      formatted_lines = [] of String
      documentation.lines(chomp: false).each do |line|
        # Ignore blank lines - we'll add these later
        if ["\r", "\n\n", "\n\r"].includes?(line)
          formatted_lines.push "\n"
        elsif line.empty?
          # break
          # formatted_lines.push "\n"
        end
        # if line is less that screen width just add it - no questions asked!
        if line.size < width
          formatted_lines.push line
          # break
        end

        if line.size >= width
          words = line.split(' ')
          words = words.flat_map { |word|
            # for words that are longer than the width
            if word.size >= width
              word.chars.to_a.each_slice(width).to_a.map { |w| w.join }
            else
              word
            end
          }
          formatted_line = String::Builder.new
          words.each do |word|
            if formatted_line.empty?
              formatted_line << word
            else
              formatted_line << " " << word
            end
            # temp_string = Object.new.copy formatted_line
            if formatted_line.bytesize > width
              # delete the extra word and add to next line
              formatted_line.back(word.size + 1)
              formatted_lines.push formatted_line.to_s.lstrip.chomp
              formatted_line = String::Builder.new(word.lstrip)
            end
          end
        end
      end
      # if we reach the end of the words, check if formatted_line is empty and append
      unless formatted_line.empty?
        formatted_lines.push formatted_line.to_s.lstrip.chomp
      end
      formatted_lines
    end
  end
end
