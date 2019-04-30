require "toml"
require "file_utils"

module SniplineCli
    class Config
        def initialize
            config_file = File.read(File.expand_path("~/.config/snipline/config.toml"))
            toml = TOML.parse(config_file)
            @api = toml["api"].as(Hash(String, TOML::Type))
            @general = toml["general"].as(Hash(String, TOML::Type))
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
    end
end