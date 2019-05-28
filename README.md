# Snipline CLI

Snipline CLI is the command-line tool for [Snipline](https://snipline.io).

[![asciicast](https://asciinema.org/a/R5vM238erVaOo62TYvHceixz3.svg)](https://asciinema.org/a/R5vM238erVaOo62TYvHceixz3)

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

Follow login instructions (Enter email and token)

```bash
snipline login
```

Download snippets from your account

```bash
snipline sync
```

This will create two files on your system: `~/.config/snipline/config.toml` and `~/.config/snipline/snippets.json`.

### Searching snippets

A basic search can be done with the `search` command.

```bash
snipline search <searchterm>
```

Search options include `field`, and `limit`. See `snipcli search --help` for more information

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

See the Installation section on building from source. 

Set log levels for additional development output.

```bash
crystal build src/snipline_cli.cr -o snipcli
env LOG_LEVEL=DEBUG ./snipcli search git
```

To change the config file location (For testing) use the `CONFIG_FILE` environment variable.

```bash
env CONFIG_FILE=./spec/fixtures/config.toml ./snipcli search git
```

## Contributing

See the [Contributing guide](CONTRIBUTING.md) for details.

## TODO

* More tests.
* Create snippets through web interface.
* Edit snippets through web interface.
* Delete snippets through web interface.
* More documentation (Including code docs)
* Table formatting for search results

## Contributors

- [Mitchell Stanley](https://github.com/acoustep) - creator and maintainer
