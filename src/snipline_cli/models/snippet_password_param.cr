module SniplineCli::Models
  # A password parameter of a snippet.
  #
  # When a snippet has the text `#password{[Name]}` it becomes a password parameter
  struct SnippetPasswordParam
    property id : String
    property length : UInt32 | UInt8
    property full : String

    def initialize(@id : String, @length : UInt32 | UInt8, @full : String)
    end
  end
end
