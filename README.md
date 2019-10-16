# Snipline CLI

Snipline CLI is the command-line tool for [Snipline](https://snipline.io).

![SnipCLI Preview](https://f002.backblazeb2.com/file/snipline/2019-10-14+12.02.35.gif)

Snipline CLI allows you to organise your favourite shell commands from the terminal. It can optionally sync to your [Snipline](https://snipline.io) account.

## Installation

### Homebrew (MacOS and Linux)

Snipline CLI is available through Homebrew for MacOS and Linux.

```bash
brew install snipline/snipline/snipcli
```

### Snapcraft (Linux)

Linux users can download via Snapcraft

```
sudo snap install snipcli --beta
```

### From source

Snipline CLI requires Crystal 0.30.1 to be installed to install from source

```bash
# Install dependencies
shards
# Build app
crystal build src/snipline_cli.cr -o snipcli --release
```

## Usage

### Using Snipline CLI for free

Snipline CLI can be used without an active Snipline account.

To generate the initial configuration files use the `init` command.

```bash
snipcli init
```

The above command will generate a `config.toml` file and a `snippets.json` file in your `~/.config/snipline` directory.

### Syncing to Snipline

Log-in to your Snipline account and sync your snippets.

Follow login instructions (Enter email and token)

```bash
snipcli login
```

### Download snippets from your Snipline account

**Note:: At the time of writing this will clear any unsynced snippets on your machine. This will be changed with a future update**

```bash
snipcli sync
```

### Searching snippets

A basic search can be done with the `search` command.

```bash
snipcli search
```

If you wish to pre-filter the results you can do so by adding a search term and specify the field to search on.

```bash
snipcli search <searchterm> --field=tags
```

Search options include `field` and `limit`. See `snipcli search --help` for more information

Note that as of 0.2.0 it's not possible to search and copy to clipboard from a Linux VM/SSH session. Use `run` to run the command directly from your terminal session.

### Creating a new snippet

You can create a new snippet by using the `new` command. This will open a TOML file in the text editor of your preference. Once closed it will attempt to add it to your `snippets.json` file and sync to your Snipline Account.

```bash
snipcli new
```

### Web interface

As of 0.3.0 the web interface has been removed infavour of the new TUI.

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
* More documentation (Including usage without a Snipline account).
* Syncing local snippets via `snipcli sync`.
* Editing snippets.
* Compact search mode.

## Contributors

- [Mitchell Stanley](https://github.com/acoustep) - creator and maintainer
