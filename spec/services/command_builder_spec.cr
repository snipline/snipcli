describe SniplineCli::Services::CommandBuilder do
  it "correctly parses snippets with no params" do
    attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"Git log pretty","real-command":"git log --oneline --decorate --graph --all","tags":["git"]}})
    snippet = SniplineCli::Snippet.from_json(attributes)
    response = SniplineCli::Services::CommandBuilder.run(snippet)

    response.should eq("git log --oneline --decorate --graph --all")
  end

  it "should generate random passwords" do
    attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"random password generator","real-command":"rand '#password{[Name,8]}' #password{[Name]} #password{[Diff,4]}","tags":["git"]}})
    snippet = SniplineCli::Snippet.from_json(attributes)
    response = SniplineCli::Services::CommandBuilder.run(snippet)

    response.size.should eq(29)
    split = response.split("'")
    first_password = split[1]
    # If the second half of the split also has the same password
    # This checks if the password with the same name is repeating correctly.
    "#{split[2]}".includes?(split[1])
  end

  it "should parse variables with defaults" do

    attributes = %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"random password generator","real-command":"echo '\#{[Hello=world]}'","tags":["git"]}})
    # params = SniplineCli::SnippetParam.new(
    #     "", @default_value : String, @full : String, @type : String, @options : Array(String))

    # property name : String
    # property default_value : String
    # property full : String
    # property type : String
    # property options : Array(String)
    # snippet = SniplineCli::Snippet.from_json(attributes)
    # response = SniplineCli::Services::CommandBuilder.run(snippet)
    # response.should eq("echo 'world'")
  end
end