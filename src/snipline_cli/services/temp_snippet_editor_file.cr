require "toml"

module SniplineCli::Services
  # For saving Snippets locally.
  class TempSnippetEditorFile

    include SniplineCli::Models

		property snippet : SnippetSchema | Nil

    property template = %<# Welcome to the terminal-based snippet editor
# This file uses TOML syntax and will be processed after the file is saved and closed
# Fill in the below options and save+quit to continue
name = ""
real_command = """
echo 'hello, world'
"""
documentation = """
This section supports **Markdown**
"""
is_pinned = false
snippet_alias = ""
sync_to_cloud = #{SniplineCli.config.get("api.token") == "" ? "false" : "true"}
>
	
		def initialize(@snippet : SnippetSchema | Nil = nil)
			snippet = @snippet
			if (snippet = @snippet).is_a?(SnippetSchema)
				@template = %<# Welcome to the terminal-based snippet editor
# This file uses TOML syntax and will be processed after the file is saved and closed
# Fill in the below options and save+quit to continue
name = "#{snippet.name}"
real_command = """
#{snippet.real_command}
"""
documentation = """
#{snippet.documentation}
"""
is_pinned = #{snippet.is_pinned}
snippet_alias = "#{snippet.snippet_alias}"
sync_to_cloud = #{SniplineCli.config.get("api.token") == "" ? "false" : "true"}
>
			end
		end

    def create
      config = SniplineCli.config
      unless File.exists?(File.expand_path("#{config.get("general.temp_dir")}/temp.toml"))
        File.write(File.expand_path("#{config.get("general.temp_dir")}/temp.toml"), @template)
      end
    end

    def read
      config = SniplineCli.config
      toml = TOML.parse(File.read(File.expand_path("#{config.get("general.temp_dir")}/temp.toml")))
      SnippetAttribute.new(
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
      toml = TOML.parse(File.read(File.expand_path("#{config.get("general.temp_dir")}/temp.toml")))
      toml["sync_to_cloud"].as(Bool)
    end

    def delete
      config = SniplineCli.config
      if File.exists?(File.expand_path("#{config.get("general.temp_dir")}/temp.toml"))
        File.delete(File.expand_path("#{config.get("general.temp_dir")}/temp.toml"))
      end
    end
  end
end
