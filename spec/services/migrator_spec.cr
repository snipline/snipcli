describe SniplineCli::Services::Migrator do
  after_each do
    if File.exists?("./snippets.json")
      File.delete("./snippets.json")
    end
    if File.exists?("./test.db")
      File.delete("./test.db")
    end
  end

  it "should create and migrate a DB from scratch" do
    File.exists?("./test.db").should eq(false)
    SniplineCli::Services::Migrator.run
    File.exists?("./test.db").should eq(true)
    DB.open "sqlite3:./test.db" do |db|
      db.scalar("select count(*) from snippets").should eq(0)
    end
  end

  it "should import any previously created json snippets" do
    # File.write("./snippets.json", File.read("./spec/fixtures/snippets.json"))
    FileUtils.cp({"./spec/fixtures/snippets.json"}, "./")
    File.exists?(File.expand_path(SniplineCli.config.get("general.file"), home: true)).should eq(true)
    SniplineCli::Services::Migrator.run
    DB.open "sqlite3:./test.db" do |db|
      db.scalar("select count(*) from snippets").should eq(2)
    end
    #
    File.exists?("./snippets.json").should eq(false)
  end
end
