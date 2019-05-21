describe SniplineCli::SnippetParam do
  it "correctly parses snippets params" do
    param = SniplineCli::SnippetParam.new("Test Snippet", "default", "Test Snippet=default", "variable", [] of String)
    param.name.should eq "Test Snippet"
    param.default_value.should eq "default"
    param.full.should eq "Test Snippet=default"
    param.type.should eq "variable"
    param.options.should eq [] of String
  end
end
