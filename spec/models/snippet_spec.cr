def set_attribute(attributes, attribute_name, default = nil)
  (!attributes.nil? && attributes.has_key?(attribute_name)) ? attributes[attribute_name] : default
end

def create_test_snippet(attributes : NamedTuple | Nil = nil)
  snippet = SniplineCli::Models::Snippet.new
  snippet.local_id = set_attribute(attributes, :local_id, 123).as(Int32)
  snippet.cloud_id = set_attribute(attributes, :cloud_id)
  snippet.name = set_attribute(attributes, :name, "Git log pretty")
  snippet.snippet_alias = set_attribute(attributes, :snippet_alias, "git.sla")
  snippet.is_pinned = set_attribute(attributes, :is_pinned, false).as(Bool)
  snippet.real_command = set_attribute(attributes, :real_command, "git log --oneline --decorate --graph --all")
  snippet.tags = set_attribute(attributes, :tags, "git")
  snippet.documentation = set_attribute(attributes, :documentation, "This is the docs")

  snippet
end

describe SniplineCli::Models::Snippet do
  it "parses with no parameters" do
    snippet = create_test_snippet()
    snippet.snippet_alias.should eq("git.sla")
    snippet.name.should eq("Git log pretty")
    snippet.is_pinned.should eq(false)
    snippet.real_command.should eq("git log --oneline --decorate --graph --all")
    snippet.preview_command.should eq("git log --oneline --decorate --graph --all")
    snippet.tags.should eq("git")
    snippet.has_params.should eq(false)
    snippet.interactive_params.should eq([] of SniplineCli::Models::SnippetParam)
    snippet.uninteractive_params.should eq([] of SniplineCli::Models::SnippetPasswordParam)
  end
  it "#value_for_attribute" do
    snippet = create_test_snippet(nil)
    snippet.value_for_attribute("alias").should eq("git.sla")
    snippet.value_for_attribute("name").should eq("Git log pretty")
    snippet.value_for_attribute("tags").should eq("git")
    snippet.value_for_attribute("documentation").should eq("This is the docs")
  end
  describe "#interactive_params" do
    it "should be able to parse a variable with a default value" do
      snippet = create_test_snippet({name: "Test", real_command: "git log -S \#{[Test=default]}"})
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("default")
      snippet.interactive_params.first.full.should eq("Test=default")
      snippet.interactive_params.first.type.should eq("variable")
    end
    it "should be able to parse a variable without a default value" do
      snippet = create_test_snippet({name: "Search Git history", real_command: "git log -S \#{[Test]} "})
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("")
      snippet.interactive_params.first.full.should eq("Test")
      snippet.interactive_params.first.type.should eq("variable")
    end

    it "should be able to parse multiple variables" do
      snippet = create_test_snippet({name: "Test", real_command: "git log -S \#{[Test]} \#{[Example=test]} "})
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
      snippet = create_test_snippet({name: "Search Git history", real_command: "git log -S #select{[Test=option 1, option 2]} "})
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(1)
      snippet.interactive_params.first.name.should eq("Test")
      snippet.interactive_params.first.default_value.should eq("")
      snippet.interactive_params.first.full.should eq("Test=option 1, option 2")
      snippet.interactive_params.first.type.should eq("select")
      snippet.interactive_params.first.options.should eq(["option 1", "option 2"])
    end

    it "should be able to parse password variables" do
      snippet = create_test_snippet({name: "Search Git history", real_command: "magento user:create #password{[Name,8]} #password{[Default]}"})
      snippet.has_params.should eq(true)
      snippet.interactive_params.size.should eq(0)
      snippet.preview_command.should eq("magento user:create <PW:Name> <PW:Default>")
    end
  end
end
