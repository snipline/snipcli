describe SniplineCli::SnippetPasswordParam do
  it "correctly parses password params" do
    param = SniplineCli::SnippetPasswordParam.new("PWName", 12.to_u32, "PWName,12")
    param.id.should eq "PWName"
    param.length.should eq 12
    param.full.should eq "PWName,12"
  end
end
