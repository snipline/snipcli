require "json"

module SniplineCli
    class Command < Admiral::Command
		class Search < Admiral::Command
			define_help description: "For searching your snippets"
			def run
				puts "Searching..."
                Crest.get(
                    "http://localhost:4001/api/snippets",
                    headers: {
                        # "Accept" => "application/vnd.api+json",
                        "Authorization" => "Bearer #{ENV["TOKEN"]}",
                    }) do |resp|
                        # puts response.body.inspect
                        snippets = SnippetDataWrapper.from_json resp.body
                        puts snippets.inspect
                        snippets.data.each do |snippet|
                            puts "#{snippet.attributes.name} - #{snippet.attributes.is_pinned ? "✅" : "❌"}"
                        end
                        # snippets.each do |snippet|
                        #     puts "#{snippet.name}"
                        # end
                        # body = JSON.parse(resp.body)
                        # data = body["data"]
                        # snippets = Snippet.from_json(data)
                        # puts data.inspect
                        # parsed_data = data["data"].as(Array)
                        # parsed_data.each do |d|
                        # end
                        # case parsed_data
                        # when Array(JSON::Any)
                        #     puts "woot"
                        # else
                        #     puts "nope"
                        # end
                        # parsed_data.each do |snippet|
                        #     puts snippet["name"]
                        # end
                end
			end
		end
		register_sub_command :search, Search
    end
end