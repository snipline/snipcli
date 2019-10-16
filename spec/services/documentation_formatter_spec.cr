describe SniplineCli::Services::DocumentationFormatter do
  it "returns empty when nil is passed" do
		formatter = setup_formatter()
		formatter.to_ncurses(nil).should eq("No documentation found")
	end

	it "puts lines over its width onto new lines" do
		formatter = setup_formatter(width: 20)
		formatter.format_documentation("This sentence is longer than 20 characters", 20).should eq(["This sentence is", "longer than 20", "characters"])
	end

	it "splits words over the character limit onto new lines" do
		formatter = setup_formatter(width: 20)
		formatter.format_documentation("pneumonoultramicroscopicsilicovolcanoconiosis", 20).should eq(["pneumonoultramicrosc", "opicsilicovolcanocon", "iosis"])
	end

	it "works with a realistic example" do
		formatter = setup_formatter()
		formatter.format_documentation("Find files that contain the `searchterm`.\n\nUsing `l` will show filenames for results. Not using `l` will show contents.", 500).should eq(["Find files that contain the `searchterm`.\n", "\n", "Using `l` will show filenames for results. Not using `l` will show contents."])
	end

end

