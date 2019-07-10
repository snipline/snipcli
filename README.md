# Snipline CLI

Snipline CLI is the command-line tool for [Snipline](https://snipline.io).

![SnipCLI Preview](https://f002.backblazeb2.com/file/ms-uploads/snipline/2019-07-10%2010.41.26.gif)

Snipline CLI allows you to search and run commands from your Snipline account directly through the command-line. It is also possible to use this for free without a Snipline account (See the documentation on using without a Snipline Account).

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

Snipline CLI requires Crystal 0.29.0 to be installed to install from source

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

Snipline CLI can be used without an active Snipline account. But requires either manually entering data in the `~/.config/snipline/snippets.json` file or using the `web` interface.

To generate the initial configuration files use the `init` command.

```bash
snipcli init
```

At this moment the web interface does not support CRUD commands and manual entry is required.

Here is an example ~/.config/snipline/snipets.json` file to get started.

Note that `id` of `null` means that it has not been synced to a Snipline account. It will be lost if `snipcli sync` is ever run to fetch snippets from Snipline.

```json
[
    {
        "id":null,
        "type":"snippets",
        "attributes":
        {
            "is-pinned":false,
            "name":"Symlink directory",
            "real-command":"ln -s #{[Source]} #{[Destination]}",
            "tags":["file", "linux"]
        }
    }
]
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
* More documentation (Including usage without a Snipline account).
* Table formatting for search results.

## Contributors

- [Mitchell Stanley](https://github.com/acoustep) - creator and maintainer
