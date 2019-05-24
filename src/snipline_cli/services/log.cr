require "logger"

module SniplineCli
  module Services
    # Log is a wrapper around the Crystal `Logger`.
    #
    # Example Usage
    #
    # ```crystal
    # log = SniplineCli.log
    # config = SniplineCli.config
    # log.info("Looking through file #{config.get("general.file")}")
    # ```
    #
    # The output level can then be specified at run-time.
    #
    # ```bash
    # env LOG_LEVEL=WARN snipcli sync
    # ```
    class Log

      # Constant that creates a fresh version of itself - for use with self.log.
      INSTANCE = Log.new

      property logger : Logger

      def initialize
        ENV["LOG_LEVEL"] ||= "WARN"
        @logger = Logger.new(STDOUT, level: (ENV["LOG_LEVEL"] == "DEBUG") ? Logger::DEBUG : Logger::WARN)
      end

      # The static convenience method for retreiving the Log class instance without regenerating it.
      def self.log
        Log::INSTANCE
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
