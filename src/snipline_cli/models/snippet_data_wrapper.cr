require "json"

module SniplineCli
  class SnippetDataWrapper
    JSON.mapping({
      data: Array(Snippet),
    })
  end
end
