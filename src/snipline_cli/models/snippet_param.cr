module SniplineCli::Models
  # A single dynamic parameter which is apart of a Snippet
  #
  # When a snippet includes the text `#{[Param=value]}` or #{[Param]}` this becomes a parameter.
  struct SnippetParam
    property name : String
    property default_value : String
    property full : String
    property type : String
    property options : Array(String)

    def initialize(@name : String, @default_value : String, @full : String, @type : String, @options : Array(String))
    end
  end
end
