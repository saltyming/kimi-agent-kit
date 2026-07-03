KIMI_CODE_HOME ?= $(HOME)/.kimi-code

AGENTS_FILE := $(KIMI_CODE_HOME)/AGENTS.md
RULES_DIR   := $(KIMI_CODE_HOME)/rules
SKILLS_DIR  := $(KIMI_CODE_HOME)/skills
MANIFEST    := $(KIMI_CODE_HOME)/.kimi-agent-kit-manifest

SIGNATURE        := slate-agent-kit:common
CUSTOM_SIGNATURE := kimi-agent-kit-custom

RULE_FILES := $(wildcard kimi-rules/kimi-agent-kit--*.md)
SKILL_NAMES := palette-init palette-rules palette-spec palette-ui palette-ux

.DEFAULT_GOAL := help
.PHONY: help install uninstall validate

help:
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install AGENTS.md, rules, and skills into KIMI_CODE_HOME
	@mkdir -p "$(KIMI_CODE_HOME)" "$(RULES_DIR)" "$(SKILLS_DIR)"
	@echo "## install @ $$(date -u +%FT%TZ 2>/dev/null || date)" > "$(MANIFEST)"
	@cp AGENTS.md "$(AGENTS_FILE)"
	@echo "$(AGENTS_FILE)" >> "$(MANIFEST)"
	@for f in $(RULE_FILES); do \
		dest="$(RULES_DIR)/$$(basename "$$f")"; \
		cp "$$f" "$$dest"; \
		echo "$$dest" >> "$(MANIFEST)"; \
		echo "  rule: $$dest"; \
	done
	@for s in $(SKILL_NAMES); do \
		dest="$(SKILLS_DIR)/$$s"; \
		rm -rf "$$dest"; \
		cp -R "kimi-skills/$$s" "$$dest"; \
		echo "$$dest" >> "$(MANIFEST)"; \
		echo "  skill: $$dest"; \
	done
	@echo "Installed kimi-agent-kit into $(KIMI_CODE_HOME)"

uninstall: ## Remove files installed by make install
	@if [ ! -f "$(MANIFEST)" ]; then echo "No manifest at $(MANIFEST)."; exit 0; fi
	@while IFS= read -r f; do \
		case "$$f" in "## "*) continue ;; esac; \
		if [ -d "$$f" ]; then rm -rf "$$f" && echo "  removed $$f"; \
		elif [ -f "$$f" ]; then rm -f "$$f" && echo "  removed $$f"; fi; \
	done < "$(MANIFEST)"
	@rm -f "$(MANIFEST)"
	@echo "Uninstalled."

validate: ## Sanity-check generated files
	@fail=0; \
	test -f AGENTS.md || { echo "missing AGENTS.md"; fail=1; }; \
	for f in AGENTS.md $(RULE_FILES); do \
		head -20 "$$f" | grep -Eq '<!-- (slate-agent-kit:common|kimi-agent-kit)' || { echo "bad signature: $$f"; fail=1; }; \
	done; \
	for s in $(SKILL_NAMES); do \
		test -f "kimi-skills/$$s/SKILL.md" || { echo "missing skill $$s"; fail=1; }; \
	done; \
	! grep -R -n "workslate_task\\|CLAUDE.md\\|claude-rules" AGENTS.md kimi-rules kimi-skills >/dev/null || { echo "stale Claude-specific terms found"; fail=1; }; \
	exit $$fail
