# Snipline CLI

Snipline CLI is the command-line tool for [Snipline](https://snipline.io).

TODO: Preview image here from ASCIINEMA

Snipline CLI allows you to search and run commands from your Snipline account directly through the command-line. It is also possible to use this for free withouth a Snipline account (See the documentation on using without a Snipline Account).

## Installation

### Homebrew

Snipline CLI is available through Homebrew for MacOS and Linux.

```bash
brew install snipline/snipline/snipcli
```

### Executable

Linux users can download the executable directly.

Bash:
```bash
wget "URL.tar.gz" && tar -xvzf ./URL.tar.gz && sudo mv FILE /usr/local/bin/
```

Fish:
```fish
wget "URL.tar.gz"; and tar -xvzf ./URL.tar.gz; and sudo mv FILE /usr/local/bin/
```

### From source

Snipline CLI requires Crystal 0.28.0 to be installed to install from source

```bash
# Install dependencies
shards
# Build app
crystal build src/snipline_cli.cr -o snipcli --release
```

## Usage

### Syncing to Snipline

Log-in to your Snipline account and sync your snippets.

```bash
# follow login instructions (Enter email and token)
snipline login
# download snippets from your account
snipline sync
```

This will create two files on your system: `~/.config/snipline/config.toml` and `~/.config/snipline/snippets.json`.

### Searching snippets

```
# search <searchterm>
snipline search <searchterm>

# other options
snipline search <searchterm> --field=tags --limit=10
```

### Web interface

Snipline CLI comes with a lightweight web interface. To use it run

```
snipcli web
```

You can then view and edit snippets through a web browser. By default this works locally on port 9876, however, you can specify it to be accessible remotely with the following arguments.

```bash
snipcli web -p 3000 -b 0.0.0.0
```

### Using Snipline CLI without a Snipline Account

Snipline CLI can be used without an active Snipline account. But requires either manually entering data in the `snippets.json` file or using the `web` interface.

To generate the initial configuration files use the `init` command.

```bash
snipcli init
```

## Development

See the above details on building from source. 

Set log levels for additional development output.

```bash
env LOG_LEVEL=DEBUG ./snipcli search git
```

To change the config file location (For testing) use the `CONFIG_FILE` environment variable.

```bash
env CONFIG_FILE=./spec/fixtures/config.toml ./snipcli search git
```

## Contributing

Contributions are welcome, but for new features please open an issue first to discuss it.

1. Fork it (<https://github.com/snipline/snipline_cli/fork>)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Run the tests `crystal spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin feature/my-new-feature`)
6. Create a new Pull Request

## TODO

* More tests.
* Create snippets through web interface.
* Edit snippets through web interface.
* Delete snippets through web interface.
* More documentation (Including code docs)

## Contributors

- [Mitchell Stanley](https://github.com/acoustep) - creator and maintainer
