# Changelog

## 0.3.1

### Changes

* Update temp snippet TOML file to include instructions for escaping quotes in commands and documentation

### Bugfixes

* Escape quotes in commands, documentation, and snippet name when editing a snippet
* Remove debug output after saving an edited snippet
* Always create a new temp snippet file even when it exists to prevent editing the wrong snippet

## 0.3.0

### Features

* Upgraded Crystal to 0.31.1
* Overhauled the search command
	* New NCurses TUI
	* Fuzzy match searching.
	* Deleting snippets via search.
	* Editing snippets via search.
	* Copy/run snippets via search
* Ability to edit and delete commands through the search interface.
* Moved from JSON storage to Sqlite - including a built in migration process
* Syncing snippets improvements:
	* New local-only snippets will sync back to Snipline Cloud.
	* Snipline Cloud snippets will now delete locally on sync.
	* Locally edited snippets will sync back to Snipline Cloud.
	* New `--dry-run` flag to see what will change during sync.
	* New `--verbose` flag to see what has changed during sync.

### Changes

* Refactoring and testing to various classes.
* Snippets are now stored in an Sqlite database rather than JSON file.
* `sync` command now migrates the Sqlite database.
* Added Crecto for managing snippets from Sqlite.

### Bugfixes

None

## 0.2.0

### Features

* Added `new` command to create new snippets from command line.
* new `--run` flag for `search` command to run the selected snippet
* Added ability to create snippets from the `web` interface.

### Changes

* `search` command now copies the selected snippet instead of running.
* Updated Crystal to `0.30.1`
* Updated `lodash` dependency for `web` interface.
* Removed `web` command.

### Bugfixes

None!
