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

    it "parses parameters" do
        snippet = create_test_object(nil)
        snippet.snippet_alias.should eq("git.sla")
        snippet.name.should eq("Git log pretty")
        snippet.is_pinned.should eq(false)
        snippet.real_command.should eq("git log --oneline --decorate --graph --all")
        snippet.preview_command.should eq("git log --oneline --decorate --graph --all")
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

        pending "should be able to parse a variable without a default value" do
        end

        pending "should be able to parse multiple variables" do
        end

        pending "should be able to parse multiple choice variables" do
        end

        pending "should be able to parse password variables" do
        end
    end

end