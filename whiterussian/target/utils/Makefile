include $(TOPDIR)/rules.mk

TARGETS := addpattern trx motorola-bin trx2usr

UTILS_BUILD_DIR:=$(BUILD_DIR)/target-utils

prepare: $(UTILS_BUILD_DIR)
compile: prepare $(patsubst %,$(UTILS_BUILD_DIR)/%,$(TARGETS))
	mkdir -p $(STAGING_DIR)/bin
	cp -a $(UTILS_BUILD_DIR)/* $(STAGING_DIR)/bin/
install: compile
package:
clean:
	rm -rf $(UTILS_BUILD_DIR)

$(UTILS_BUILD_DIR):
	mkdir -p $(UTILS_BUILD_DIR)
	
$(UTILS_BUILD_DIR)/%: src/%.c
	$(HOSTCC) -o $@ $(patsubst $(UTILS_BUILD_DIR)/%,src/%.c,$@)
	chmod 755 $@

