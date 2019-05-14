describe SniplineCli::Token do
  it "correctly parses JWT tokens" do
    content = %({"jwt": "test_token_here"})
    token = SniplineCli::Token.from_json(content)
    token.jwt.should eq("test_token_here")
  end
end
