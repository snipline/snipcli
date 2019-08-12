require "json"

module SniplineCli::Services
  # For talking to the Snipline API.
  class SniplineApi
    # Fetches the user's Snippets.
    def fetch(&block)
      config = SniplineCli.config
      resp = Crest.get(
        "#{config.get("api.url")}/snippets",
        headers: {
          # "Accept" => "application/vnd.api+json",
          "Authorization" => "Bearer #{config.get("api.token")}",
        }
      )
      yield resp.body
    end

    def create(snippet : Snippet)
      config = SniplineCli.config
      resp = Crest.post(
        "#{config.get("api.url")}/snippets",
        headers: {
          # "Accept" => "application/vnd.api+json",
          "Authorization" => "Bearer #{config.get("api.token")}",
        },
        form: {
          # data: {
            :name => snippet.name,
            :real_command => snippet.real_command,
            :documentation => snippet.documentation,
            :alias => snippet.snippet_alias,
            :is_pinned => snippet.is_pinned.to_s,
            # :tags => snippet.tags
          # }
        }
      )
      # Snippet.from_json(resp.body)
      SingleSnippetDataWrapper.from_json(resp.body).data
    end
  end

  class SniplineApiTest
    def fetch(&block)
      yield "{\"data\":[{\"attributes\":{\"alias\":\"git.sla\",\"documentation\":null,\"is-pinned\":false,\"name\":\"Git log pretty\",\"real-command\":\"git log --oneline --decorate --graph --all\",\"tags\":[]},\"id\":\"0f4846c0-3194-40bb-be77-8c4b136565f4\",\"type\":\"snippets\"}]}"
    end
  end
end
