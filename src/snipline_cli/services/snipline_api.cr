require "json"

module SniplineCli::Services
  # For talking to the Snipline API.
  class SniplineApi
    include SniplineCli::Models

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
      # begin
      resp = Crest.post(
        "#{config.get("api.url")}/snippets",
        headers: {
          # "Accept" => "application/vnd.api+json",
          "Authorization" => "Bearer #{config.get("api.token")}",
        },
        form: {
          # data: {
          :name          => snippet.name.chomp,
          :real_command  => snippet.real_command.chomp,
          :documentation => snippet.documentation,
          :alias         => snippet.snippet_alias,
          :is_pinned     => snippet.is_pinned.to_s,
          # :tags => snippet.tags
          # }
        },
        logging: ENV["LOG_LEVEL"] == "DEBUG" ? true : false
      )
      # Snippet.from_json(resp.body)
      SingleSnippetDataWrapper.from_json(resp.body).data
      # rescue ex : Crest::UnprocessableEntity
      #   puts "RAISING"
      #   puts resp.inspect
      #   unless resp.nil?
      #     errors = SnippetErrorResponse.from_json(resp.not_nil!.body)
      #     raise SniplineCli::Exceptions::InvalidSnippet.new(errors)
      #   end
      # rescue ex

      #   puts "OTHER"
      #   raise ex
      # end
    end
  end

  class SniplineApiTest
    def fetch(&block)
      yield "{\"data\":[{\"attributes\":{\"alias\":\"git.sla\",\"documentation\":null,\"is-pinned\":false,\"name\":\"Git log pretty\",\"real-command\":\"git log --oneline --decorate --graph --all\",\"tags\":[]},\"id\":\"0f4846c0-3194-40bb-be77-8c4b136565f4\",\"type\":\"snippets\"}]}"
    end
  end
end
