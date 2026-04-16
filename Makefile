PROJECT_DIR := firmware

.DEFAULT_GOAL := all

.PHONY: all clean flash print debug release size rebuild list

all clean flash print debug release size rebuild list:
	@$(MAKE) -C $(PROJECT_DIR) $@
