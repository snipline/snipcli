# TODO: Write documentation for `SniplineCli`
require "admiral"
require "crest"
# require "./snipline_cli/*"
require "./snipline_cli/config/config"
require "./snipline_cli/models/*"
require "./snipline_cli/services/*"
require "./snipline_cli/commands/*"
require "toml"

module SniplineCli
  VERSION = "0.1.0"

  def self.config
    SniplineCli::Config.config
  end

  def self.config_file
      ENV.has_key?("CONFIG_FILE") ? ENV["CONFIG_FILE"] : "~/.config/snipline/config.toml"
  end

  def self.log
    SniplineCli::Services::Log.log
  end

  class Command < Admiral::Command
    define_version "0.1.0"
    define_help description: "Snipline CLI"

    def run
    end
  end
end

SniplineCli::Command.run
