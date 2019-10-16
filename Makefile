PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
SNIPCLI_SYSTEM=$(INSTALL_DIR)/snipcli

OUT_DIR=./bin
SNIPCLI=$(OUT_DIR)/snipcli
SNIPCLI_SOURCES=$(shell find src/ -type f -name '*.cr')

all: build

build: lib $(SNIPCLI)

lib:
	@shards install --production

$(SNIPCLI): $(SNIPCLI_SOURCES) | $(OUT_DIR)
	@echo "Building snipcli in $@"
	@crystal build -o $@ src/snipline_cli.cr -p --no-debug --release

$(OUT_DIR) $(INSTALL_DIR):
	 @mkdir -p $@

run:
	$(SNIPCLI)

install: build | $(INSTALL_DIR)
	@rm -f $(SNIPCLI_SYSTEM)
	@cp $(SNIPCLI) $(SNIPCLI_SYSTEM)

link: build | $(INSTALL_DIR)
	@echo "Symlinking $(SNIPCLI) to $(SNIPCLI_SYSTEM)"
	@ln -s $(SNIPCLI) $(SNIPCLI_SYSTEM)

force_link: build | $(INSTALL_DIR)
	@echo "Symlinking $(SNIPCLI) to $(SNIPCLI_SYSTEM)"
	@ln -sf $(SNIPCLI) $(SNIPCLI_SYSTEM)

clean:
	rm -rf $(SNIPCLI)

distclean:
	rm -rf $(SNIPCLI) .crystal .shards libs lib