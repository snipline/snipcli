# TODO: Write documentation for `SniplineCli`
require "admiral"
require "crest"
# require "./snipline_cli/*"
require "./snipline_cli/models/*"
require "./snipline_cli/commands/*"
require "toml"

module SniplineCli
  VERSION = "0.1.0"

	class Command < Admiral::Command
		define_version "0.1.0"
		define_help description: "Snipline CLI"

		def run
			puts "Use #{"snipline login".colorize(:green)} to get started."
		end
	end
end

SniplineCli::Command.run
