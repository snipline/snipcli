require "json"

module SniplineCli
  class SnippetDataWrapper
    JSON.mapping({
      data: Array(Snippet),
    })
  end

  class SingleSnippetDataWrapper
    JSON.mapping({
      data: Snippet,
    })
  end
end
