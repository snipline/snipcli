require "json"

module SniplineCli
  struct SnippetPasswordParam
    property id : String
    property length : UInt32 | UInt8
    property full : String

    def initialize(@id : String, @length : UInt32 | UInt8, @full : String)
    end
  end
end
