describe SniplineCli::Services::CommandBuilder do
  it "correctly parses snippets with no params" do
    # attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"Git log pretty","real-command":"git log --oneline --decorate --graph --all","tags":["git"]}})
    snippet = SniplineCli::Models::Snippet.new
    snippet.name = "Git log pretty"
    snippet.snippet_alias = "git.sla"
    snippet.real_command = "git log --oneline --decorate --graph --all"
    # snippet = SniplineCli::Models::Snippet.from_json(attributes)
    File.tempfile("test") do |io|
      response = SniplineCli::Services::CommandBuilder.run(snippet, io, io)
      response.should eq("git log --oneline --decorate --graph --all")
    end
  end

  it "should generate random passwords" do
    # attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"random password generator","real-command":"rand '#password{[Name,8]}' #password{[Name]} #password{[Diff,4]}","tags":["git"]}})
    # snippet = SniplineCli::Models::Snippet.from_json(attributes)
    snippet = SniplineCli::Models::Snippet.new
    snippet.name = "Git log pretty"
    snippet.snippet_alias = "git.sla"
    snippet.real_command = "rand '#password{[Name,8]}' #password{[Name]} #password{[Diff,4]}"
    File.tempfile("test") do |io|
      response = SniplineCli::Services::CommandBuilder.run(snippet, io, io)
      response.size.should eq(29)
      split = response.split("'")
      first_password = split[1]
      # If the second half of the split also has the same password
      # This checks if the password with the same name is repeating correctly.
      "#{split[2]}".includes?(first_password)
    end
  end

  # it "should parse variables input by user" do
  #   attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"random password generator","real-command":"echo '\#{[Hello=world]}'","tags":["git"]}})
  #   # params = SniplineCli::SnippetParam.new(
  #   #     "", @default_value : String, @full : String, @type : String, @options : Array(String))
  #
  #   # property name : String
  #   # property default_value : String
  #   # property full : String
  #   # property type : String
  #   # property options : Array(String)
  #   File.tempfile("test") do |io|
  #     snippet = SniplineCli::Models::Snippet.from_json(attributes)
  #     response = SniplineCli::Services::CommandBuilder.run(snippet, io, io, ["world2"] of String)
  #     # TODO: Figure out how to pass input to tests
  #     response.should eq("echo 'world2'")
  #     io.rewind
  #     io.gets_to_end.should eq "Enter Hello:\nLeave blank for default (world)\n"
  #   end
  # end
end
