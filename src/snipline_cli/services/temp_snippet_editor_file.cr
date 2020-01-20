require "toml"
require "../helpers/*"

module SniplineCli::Services
  # Provides the users preferred text editor with a template for editing and adding new snippets.
  class TempSnippetEditorFile
    include SniplineCli::Helpers

    property snippet : Snippet | Nil

    property template = %<# Welcome to the terminal-based snippet editor
# This file uses TOML syntax and will be processed after the file is saved and closed
# Fill in the below options and save+quit to continue
name = ""
# Tip: When working with quotes make sure to escape doubles with \\ or switch to '''
real_command = """
echo 'hello, World'
"""
documentation = """
This section supports **Markdown**
"""
is_pinned = false
snippet_alias = ""
sync_to_cloud = #{SniplineCli.config.get("api.token") == "" ? "false" : "true"}
>

    def initialize(@snippet : Snippet | Nil = nil)
      snippet = @snippet
      if (snippet = @snippet).is_a?(Snippet)
        @template = %<# Welcome to the terminal-based snippet editor
# This file uses TOML syntax and will be processed after the file is saved and closed
# Fill in the below options and save+quit to continue
name = "#{snippet.name ? snippet.name.not_nil!.gsub("\"", "\\\"") : ""}"
# Tip: When working with quotes make sure to escape doubles with \\ or switch to '''
real_command = """
#{snippet.real_command ? snippet.real_command.not_nil!.gsub("\"", "\\\"") : ""}
"""
documentation = """
#{snippet.documentation ? snippet.documentation.not_nil!.gsub("\"", "\\\"") : ""}
"""
is_pinned = #{snippet.is_pinned}
snippet_alias = "#{snippet.snippet_alias}"
sync_to_cloud = #{SniplineCli.config.get("api.token") == "" ? "false" : "true"}
>
      end
    end

    def create
      config = SniplineCli.config
      File.write(expand_path("#{config.get("general.temp_dir")}/temp.toml"), @template)
    end

    def read
      config = SniplineCli.config
      toml = TOML.parse(File.read(expand_path("#{config.get("general.temp_dir")}/temp.toml")))
      SnippetAttributeParser.new(
        name: toml["name"].as(String),
        real_command: toml["real_command"].as(String),
        documentation: toml["documentation"].as(String).rstrip,
        is_pinned: toml["is_pinned"].as(Bool),
        snippet_alias: parse_snippet_alias(toml["snippet_alias"]),
        tags: [] of String
      )
    end

    def parse_snippet_alias(snippet_alias)
      str = snippet_alias.as(String)
      if str == ""
        nil
      else
        str
      end
    end

    def sync_to_cloud?
      config = SniplineCli.config
      toml = TOML.parse(File.read(expand_path("#{config.get("general.temp_dir")}/temp.toml")))
      toml["sync_to_cloud"].as(Bool)
    end

    def delete
      config = SniplineCli.config
      if File.exists?(expand_path("#{config.get("general.temp_dir")}/temp.toml"))
        File.delete(expand_path("#{config.get("general.temp_dir")}/temp.toml"))
      end
    end
  end
end
