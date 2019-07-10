require "toml"
require "file_utils"

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
    # Constant that creates a fresh version of itself - for use with self.config.
    INSTANCE = Config.new

    # When a new instance is created the config file is read and parsed.
    def initialize
      if File.exists?(File.expand_path(SniplineCli.config_file))
        config_file = File.read(File.expand_path(SniplineCli.config_file))
        toml = TOML.parse(config_file)
        @api = toml["api"].as(Hash(String, TOML::Type))
        @general = toml["general"].as(Hash(String, TOML::Type))
      else
        @api = {"url" => "https://api.snipline.io/api", "token" => ""}
        @general = {"file" => "~/.config/snipline/snippets.json"}
      end
    end

    # Used for retreiving the value for a given key
    def get(key : String)
      case key
      when "api.url"
        @api["url"].as(String)
      when "api.token"
        @api["token"].as(String)
      when "general.file"
        @general["file"].as(String)
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
