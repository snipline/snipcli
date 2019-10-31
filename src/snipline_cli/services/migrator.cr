require "db"
require "sqlite3"

module SniplineCli::Services
	class Migrator
		def self.run
			File.write(File.expand_path("~/.config/snipline/snipline.db"), "", mode: "w") unless File.exists?(File.expand_path("~/.config/snipline/snipline.db"))
			DB.open "sqlite3:#{File.expand_path("~/.config/snipline/snipline.db")}" do |db|
				db.exec "create table if not exists snippets (
					local_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
					cloud_id TEXT NULL,
					name TEXT NOT NULL, 
					snippet_alias TEXT NULL UNIQUE,
					documentation TEXT NULL,
					real_command TEXT NOT NULL,
					tags TEXT NULL,
					is_synced BOOLEAN DEFAULT 0,
					is_pinned BOOLEAN DEFAULT 0,
					inserted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
					updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
					)"
				db.exec "create table if not exists schema (version)"
				begin
					db.query_one "select version from schema", &.read(Int)
				rescue ex : DB::Error
					db.exec "insert into schema (version) values (?)", 1
				end
			end
		end
	end
end
