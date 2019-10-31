module SniplineCli::Models
	class SnippetSchema < Crecto::Model
		set_created_at_field :inserted_at

		schema "snippets" do
			field :local_id, Int32, primary_key: true
      field :cloud_id, String
			field :name, String
      field :real_command, String
      field :documentation, String
      field :tags, String
      field :snippet_alias, String
      field :is_pinned, Bool
      field :is_synced, Bool
		end

		validate_required [:name, :real_command]
		unique_constraint :snippet_alias
		unique_constraint :name
  end
end
