module SniplineCli
    module Gateways
        class CommandBuilder
            def self.run(snippet : Snippet) : String
                unless snippet.has_params
                    return snippet.real_command
                end
                "TODO"
            end
        end
    end
end
