require "toml"
require "file_utils"
require "./helpers/*"

module SniplineCli
  # SniplineCli::Config is for easily retreiving configuration throughout the codebase.
  #
  # Example usage:
  #
  # ```crystal
  # config = SniplineCli.config
  # config.get("api.url")
  # ```
  class Config
    include SniplineCli::Helpers
    # Constant that creates a fresh version of itself - for use with self.config.
    INSTANCE = Config.new

    # When a new instance is created the config file is read and parsed.
    def initialize
      if File.exists?(expand_path(SniplineCli.config_file))
        config_file = File.read(expand_path(SniplineCli.config_file))
        toml = TOML.parse(config_file)
        @api = toml["api"].as(Hash(String, TOML::Type))
        @general = toml["general"].as(Hash(String, TOML::Type))
      else
        @api = {"url" => "https://api.snipline.io/api", "token" => ""}
        @general = {
          "db"       => "~/.config/snipline/snipline.db",
          "file"     => "~/.config/snipline/snippets.json",
          "temp_dir" => "~/.config/snipline",
        }
      end
    end

    # Used for retreiving the value for a given key
    def get(key : String)
      case key
      when "api.url"
        @api["url"].as(String)
      when "api.token"
        @api["token"].as(String)
      when "general.db"
        @general.has_key?("db") ? @general["db"].as(String) : "~/.config/snipline/snipline.db"
      when "general.file"
        @general.has_key?("file") ? @general["file"].as(String) : "~/.config/snipline/snippets.json"
      when "general.temp_dir"
        @general.has_key?("temp_dir") ? @general["temp_dir"].as(String) : "~/.config/snipline"
      else
        ""
      end
    end

    # The static convenience method for retreiving the Config class instance without regenerating it.
    def self.config
      Config::INSTANCE
    end
  end
end
