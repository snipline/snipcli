require "logger"

module SniplineCli
    module Gateways
        class Log
            property logger : Logger
            def initialize
                ENV["LOG_LEVEL"] ||= "WARN"
                @logger = Logger.new(STDOUT, level: (ENV["LOG_LEVEL"] == "DEBUG") ? Logger::DEBUG : Logger::WARN)
            end

            macro define_methods(names)
                {% for name in names %}
                    def {{name}}(message : String)
                        @logger.{{name}}(message)
                    end
                {% end %}
            end

            define_methods([debug, warn, info, fatal])
        end
    end
end
