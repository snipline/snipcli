module SniplineCli::Models
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
