require "file"

def create_test_object(attributes : String | Nil)
  attributes = attributes || %({"id":"0f4846c0-3194-40bb-be77-8c4b136565f4","type":"snippets","attributes":{"alias":"git.sla","is-pinned":false,"name":"Git log pretty","real-command":"git log --oneline --decorate --graph --all","tags":["git"]}})
  SniplineCli::Snippet.from_json(attributes)
end

describe SniplineCli::SnippetParam do
  it "correctly parses snippets from JSON" do
    content = File.read(File.expand_path("./spec/fixtures/snippets.json"))
    snippets = Array(SniplineCli::Snippet).from_json(content)
    snippets.size.should eq(2)
    snippets.first.id.should eq("0f4846c0-3194-40bb-be77-8c4b136565f4")
  end

  it "parses with no parameters" do
    snippet = create_test_object(nil)
    snippet.snippet_alias.should eq("git.sla")
    snippet.name.should eq("Git log pretty")
    snippet.is_pinned.should eq(false)
    snippet.real_command.should eq("git log --oneline --decorate --graph --all")
    snippet.preview_command.should eq("git log --oneline --decorate --graph --all")
    snippet.preview_command_in_html.should eq("git log --oneline --decorate --graph --all")
    snippet.tags.should eq(["git"])
    snippet.has_params.should eq(false)
    snippet.interactive_params.should eq([] of SniplineCli::SnippetParam)
    snippet.uninteractive_params.should eq([] of SniplineCli::SnippetPasswordParam)
  end

  it "#value_for_attribute" do
    snippet = create_test_object(nil)
    snippet.value_for_attribute("alias").should eq("git.sla")
    snippet.value_for_attribute("name").should eq("Git log pretty")
    snippet.value_for_attribute("tags").should eq("git")
    # snippet.value_for_attribute("documentation").should eq("")
  end

  describe "#interactive_params" do
    it "should be able to parse a variable with a default value" do
      snippet = create_test_object(%({"id":"0b36b3a1-f10f-42f9-857e-0caeb23b36c3","type":"snippets","attributes":{"alias":"git.s","is-pinned":false,"name":"Search Git history","real-command":"git log -S \#{[Test=default]} ","tags":[]}}))
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("default")
      snippet.interactive_params.first.full.should eq("Test=default")
      snippet.interactive_params.first.type.should eq("variable")
    end

    it "should be able to parse a variable without a default value" do
      snippet = create_test_object(%({"id":"0b36b3a1-f10f-42f9-857e-0caeb23b36c3","type":"snippets","attributes":{"alias":"git.s","is-pinned":false,"name":"Search Git history","real-command":"git log -S \#{[Test]} ","tags":[]}}))
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("")
      snippet.interactive_params.first.full.should eq("Test")
      snippet.interactive_params.first.type.should eq("variable")
    end

    it "should be able to parse multiple variables" do
      snippet = create_test_object(%({"id":"0b36b3a1-f10f-42f9-857e-0caeb23b36c3","type":"snippets","attributes":{"alias":"git.s","is-pinned":false,"name":"Search Git history","real-command":"git log -S \#{[Test]} \#{[Example=test]} ","tags":[]}}))
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(2)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("")
      snippet.interactive_params.first.full.should eq("Test")
      snippet.interactive_params.first.type.should eq("variable")
      snippet.interactive_params.last.name.should eq("Example")
      snippet.interactive_params.last.default_value.should eq("test")
      snippet.interactive_params.last.full.should eq("Example=test")
      snippet.interactive_params.last.type.should eq("variable")
    end

    it "should be able to parse multiple choice variables" do
      snippet = create_test_object(%({"id":"0b36b3a1-f10f-42f9-857e-0caeb23b36c3","type":"snippets","attributes":{"alias":"git.s","is-pinned":false,"name":"Search Git history","real-command":"git log -S #select{[Test=option 1, option 2]} ","tags":[]}}))
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("")
      snippet.interactive_params.first.full.should eq("Test=option 1, option 2")
      snippet.interactive_params.first.type.should eq("select")
      snippet.interactive_params.first.options.should eq(["option 1", "option 2"])
    end

    it "should be able to parse password variables" do
      snippet = create_test_object(%({"id":"0b36b3a1-f10f-42f9-857e-0caeb23b36c3","type":"snippets","attributes":{"alias":"git.s","is-pinned":false,"name":"Search Git history","real-command":"magento user:create #password{[Name,8]} #password{[Default]}","tags":[]}}))
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(0)
      snippet.preview_command.should eq("magento user:create \e[32m<PW:Name>\e[0m \e[32m<PW:Default>\e[0m")
      snippet.preview_command_in_html.should eq("magento user:create <span class='text-snipline-lime-dark'>&lt;PW:Name&gt;</span> <span class='text-snipline-lime-dark'>&lt;PW:Default&gt;</span>")
    end
  end
end
