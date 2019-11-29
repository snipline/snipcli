require "../spec_helper"

module SniplineCli::Services
  class StoreSnippetsTest < StoreSnippets
    def store(snippets)
    end
  end
end

describe SniplineCli::Command::Sync do
  it "Syncs snippets from server" do
    # TODO
    # sync_command = SniplineCli::Command::Sync.new
    # sync_command.snipline_api = SniplineCli::Services::SniplineApiTest.new
    # sync_command.file = SniplineCli::Services::StoreSnippetsTest.new
    # sync_command.run
  end
end
