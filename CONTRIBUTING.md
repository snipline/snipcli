# Contributing to Snipline CLI

Contributions are welcome. For new features please open an issue first to discuss it.

It is best to work from the `develop` branch as this is where the latest code is.

1. Fork it (<https://github.com/snipline/snipline_cli/fork>)
2. Checkout the develop branch (`git checkout develop`)
3. Create your feature branch (`git checkout -b feature/my-new-feature`)
4. Make your changes
5. Compile the binary `crystal build src/snipline_cli.cr -o snipcli --release
5. Confirm changes are correct `./snipcli`
3. Run the tests `crystal spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin feature/my-new-feature`).
6. Create a new Pull Request

## Developing for the web GUI.

If your feature is related to the `snipcli web` command, you may need to make updates to the CSS and JS assets. To do this you will need Node and Yarn installed.

1. Install yarn dependencies (`yarn`)
2. Make changes in `assets/css/*` and `assets/js/*`
3. Run watch or dev (`yarn run watch` or `yarn run dev`)
4. Compile the binary `crystal build src/snipline_cli.cr -o snipcli --release
5. Confirm changes are correct `./snipcli web`.