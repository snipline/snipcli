# Snipline CLI

Snipline CLI allows you to organise and use your favourite shell commands from the terminal. It can optionally sync to your [Snipline](https://snipline.io) account.

<p align="center">
	<img src="https://f002.backblazeb2.com/file/snipline/2019-10-14+12.02.35.gif" alt="SnipCLI Preview"/>
</p>

## Installation

### Homebrew (MacOS)

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
# Clone the repo
git clone git@github.com:snipline/snipcli.git
# Checkout the latest release
git checkout <tagname - e.g. 0.3.1>
# Make sure you have the same Crystal installed that's required in shard.yml
crystal -v
# Install dependencies
shards
# Build app for Crystal 0.32.1 / MacOS
crystal build src/snipline_cli.cr -o snipcli --release -o snipcli
# Build app for Crystal 0.31.1 / Linux (Alpine)
crystal build src/snipline_cli.cr -o snipcli --release -o snipcli -Dstatic_linux
./snipcli --version
```

## Upgrading

Upgrading Snipline CLI depends on your method of installation

```bash
# Homebrew
brew upgrade snipline/snipline/snipcli

# Snapcraft
snap refresh

# From Source
git pull origin master
git checkout <tagname - e.g. 0.3.1>
crystal -v # confirm Crystal is the same as shard.yml requirement
shards
crystal build src/snipline_cli.cr -o snipcli --release -o snipcli
./snipcli --version
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

There is an example already in place for testing located in `config.spec.toml`

```bash
env CONFIG_FILE=./config.spec.toml crystal spec
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
