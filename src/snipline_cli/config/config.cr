require "toml"
require "file_utils"

module SniplineCli
  class Config
    INSTANCE = Config.new

    def initialize
      ENV["CONFIG_FILE"] ||= "~/.config/snipline/config.toml"
      if File.exists?(File.expand_path(ENV["CONFIG_FILE"]))
        config_file = File.read(File.expand_path(ENV["CONFIG_FILE"]))
        toml = TOML.parse(config_file)
        @api = toml["api"].as(Hash(String, TOML::Type))
        @general = toml["general"].as(Hash(String, TOML::Type))
      else
        @api = {"url" => "https://api.snipline.io/api", "token" => ""}
        @general = {"file" => "~/.config/snipline/snippets.json"}
      end
    end

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

    def self.config
      Config::INSTANCE
    end
  end
end
