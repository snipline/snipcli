require "toml"

module SniplineCli::Services
  # For saving Snippets locally.
  class TempSnippetEditorFile
    TEMPLATE = %<# Welcome to the terminal-based snippet editor
# This file uses TOML syntax and will be processed after the file is closed
# Fill in the below options and save+quit to continue
name = ""
real_command = """
echo 'hello, world'
"""
documentation = """
This section supports **Markdown**
"""
is_pinned = true
snippet_alias = ""
>

    def create
      config = SniplineCli.config
      File.write(File.expand_path("#{config.get("general.temp_dir")}/temp.toml"), TEMPLATE)
    end

    def read
      config = SniplineCli.config
      toml = TOML.parse(File.read(File.expand_path("#{config.get("general.temp_dir")}/temp.toml")))
      SnippetAttribute.new(
        name: toml["name"].as(String),
        real_command: toml["real_command"].as(String),
        documentation: toml["documentation"].as(String),
        is_pinned: toml["is_pinned"].as(Bool),
        snippet_alias: toml["snippet_alias"].as(String),
        tags: [] of String
      )
    end
  end
end
