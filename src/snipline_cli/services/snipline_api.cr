require "json"

module SniplineCli::Services
  class SniplineApi
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
  end

  class SniplineApiTest
    def fetch(&block)
      yield "{\"data\":[{\"attributes\":{\"alias\":\"git.sla\",\"documentation\":null,\"is-pinned\":false,\"name\":\"Git log pretty\",\"real-command\":\"git log --oneline --decorate --graph --all\",\"tags\":[]},\"id\":\"0f4846c0-3194-40bb-be77-8c4b136565f4\",\"type\":\"snippets\"}]}"
    end
  end
end
