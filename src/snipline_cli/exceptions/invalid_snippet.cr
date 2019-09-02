module SniplineCli::Exceptions
  class InvalidSnippet < Exception
    def initialize(@errors : SnippetErrorResponse)
    end
  end
end
