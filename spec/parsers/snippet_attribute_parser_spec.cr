describe SniplineCli::Parsers::SnippetAttributeParser do
  it "correctly parses snippets attributes" do
    attributes = SniplineCli::Parsers::SnippetAttributeParser.from_json(
      %(
            {
                "is-pinned": true,
                "name": "Test",
                "real-command": "echo 'hello world'",
                "tags": ["sql"]
            }
        )
    )
    attributes.is_pinned.should eq true
    attributes.name.should eq "Test"
    attributes.real_command.should eq "echo 'hello world'"
    attributes.tags.should eq ["sql"]
    attributes.snippet_alias.should eq nil
    attributes.documentation.should eq nil
  end
end
