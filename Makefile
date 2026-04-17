# Makefile for HotspotGuard Module

MODULE_NAME = hotspot_blocker_ksu.zip
FILES = module.prop customize.sh service.sh dnsmasq.conf blocklist.txt action.sh system

all: zip

zip:
	@echo "Creating flashable zip..."
	zip -r $(MODULE_NAME) $(FILES)
	@echo "Done! You can now flash $(MODULE_NAME) via KernelSU."

clean:
	rm -f $(MODULE_NAME)
