require "spec"
require "../src/snipline_cli"

def setup_formatter(width : Int32 = 500)
	window = SniplineCli::NCursesWindows::MockWindow.new
	window.width = width
	SniplineCli::Services::DocumentationFormatter.new(window)
end
