require "file"

def create_test_object(attributes : String | Nil)
  attributes = attributes || %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"Git log pretty","real-command":"git log --oneline --decorate --graph --all","tags":["git"]}})
  SniplineCli::Parsers::SnippetParser.from_json(attributes)
end

describe SniplineCli::Parsers::SnippetParser do
  it "correctly parses snippets from JSON" do
    content = File.read(File.expand_path("./spec/fixtures/snippets.json"))
    snippets = Array(SniplineCli::Parsers::SnippetParser).from_json(content)
    snippets.size.should eq(2)
    snippets.first.id.should eq("0f4846c0-3194-40bb-be77-8c4b136565f4")
  end

  it "parses with no parameters" do
    snippet = create_test_object(nil)
    snippet.snippet_alias.should eq("git.sla")
    snippet.name.should eq("Git log pretty")
    snippet.is_pinned.should eq(false)
    snippet.real_command.should eq("git log --oneline --decorate --graph --all")
    snippet.tags.should eq(["git"])
  end

  it "#value_for_attribute" do
    snippet = create_test_object(nil)
    snippet.value_for_attribute("alias").should eq("git.sla")
    snippet.value_for_attribute("name").should eq("Git log pretty")
    snippet.value_for_attribute("tags").should eq("git")
    # snippet.value_for_attribute("documentation").should eq("")
  end
end
