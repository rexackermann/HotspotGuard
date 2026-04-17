# Makefile for HotspotGuard Module

VERSION = $(shell grep '^version=' module.prop | cut -d= -f2)
MODULE_NAME = HotspotGuard-$(VERSION).zip
FILES = module.prop customize.sh service.sh dnsmasq.conf blocklist.txt action.sh system LICENSE

all: zip

zip:
	@echo "Creating flashable zip..."
	zip -r $(MODULE_NAME) $(FILES)
	@echo "Done! You can now flash $(MODULE_NAME) via KernelSU."

clean:
	rm -f $(MODULE_NAME)
