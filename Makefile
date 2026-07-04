KIMI_CODE_HOME ?= $(HOME)/.kimi-code
BIN_DIR ?= $(HOME)/.local/bin
SKIP_MCP ?= 0

AGENTS_FILE := $(KIMI_CODE_HOME)/AGENTS.md
RULES_DIR   := $(KIMI_CODE_HOME)/rules
SKILLS_DIR  := $(KIMI_CODE_HOME)/skills
MANIFEST    := $(KIMI_CODE_HOME)/.kimi-code-agent-kit-manifest

SIGNATURE        := slate-agent-kit:common
CUSTOM_SIGNATURE := kimi-agent-kit

RULE_FILES := \
	kimi-rules/kimi-agent-kit--kimi-surface.md \
	kimi-rules/kimi-agent-kit--task-execution.md \
	kimi-rules/kimi-agent-kit--palette.md \
	kimi-rules/kimi-agent-kit--delegation.md \
	kimi-rules/kimi-agent-kit--git-workflow.md \
	kimi-rules/kimi-agent-kit--framework-conventions.md \
	kimi-rules/kimi-agent-kit--aside.md \
	kimi-rules/kimi-agent-kit--dispatch.md

SKILL_NAMES := palette-init palette-rules palette-spec palette-ui palette-ux

.DEFAULT_GOAL := help
.PHONY: help install uninstall validate install-mcp configure

help:
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install concatenated AGENTS.md, reference rules, skills, prefs, and MCP into KIMI_CODE_HOME
	@mkdir -p "$(KIMI_CODE_HOME)" "$(RULES_DIR)" "$(SKILLS_DIR)"
	@echo "## install @ $$(date -u +%FT%TZ 2>/dev/null || date)" > "$(MANIFEST)"
	@if [ -f "$(AGENTS_FILE)" ] && ! head -1 "$(AGENTS_FILE)" | grep -Fq '<!-- $(SIGNATURE) -->'; then \
		bak="$(AGENTS_FILE).bak-$$(date -u +%Y%m%dT%H%M%SZ)"; \
		cp -p "$(AGENTS_FILE)" "$$bak"; \
		echo "WARNING: existing $(AGENTS_FILE) is not managed by this kit; backed up to $$bak"; \
		echo "## backup: $$bak" >> "$(MANIFEST)"; \
	fi
	@: > "$(AGENTS_FILE)"
	@first=1; \
	for f in AGENTS.md $(RULE_FILES); do \
		if [ "$$first" -eq 0 ]; then printf '\n---\n\n' >> "$(AGENTS_FILE)"; fi; \
		first=0; \
		cat "$$f" >> "$(AGENTS_FILE)"; \
	done
	@printf '\n' >> "$(AGENTS_FILE)"
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
	@RULES_DIR="$(RULES_DIR)" MANIFEST="$(MANIFEST)" PREFIX="kimi-agent-kit" sh scripts/configure-prefs.sh
	@$(MAKE) --no-print-directory install-mcp
	@echo "Installed kimi-agent-kit into $(KIMI_CODE_HOME)"

configure: ## Re-run prefs configuration (PREFS_RECONFIGURE=yes to regenerate) and append CUSTOM_RULES_DIR rules
	@RULES_DIR="$(RULES_DIR)" MANIFEST="$(MANIFEST)" PREFIX="kimi-agent-kit" sh scripts/configure-prefs.sh
	@if [ -n "$${CUSTOM_RULES_DIR:-}" ] && [ -d "$${CUSTOM_RULES_DIR}" ]; then \
		for src in "$${CUSTOM_RULES_DIR}"/*.md; do \
			[ -f "$$src" ] || continue; \
			{ echo ""; echo "---"; echo ""; cat "$$src"; } >> "$(AGENTS_FILE)"; \
			echo "  custom: $$(basename "$$src")"; \
		done; \
	fi

install-mcp:
	@if [ "$(SKIP_MCP)" = "1" ]; then \
		echo "Skipping MCP registration because SKIP_MCP=1."; \
	else \
		slate_dir=""; \
		if [ -n "$${SLATE_AGENT_KIT_DIR:-}" ] && [ -x "$${SLATE_AGENT_KIT_DIR}/tooling/install-mcp.sh" ]; then slate_dir="$$SLATE_AGENT_KIT_DIR"; fi; \
		if [ -z "$$slate_dir" ] && [ -x "../slate-agent-kit/tooling/install-mcp.sh" ]; then slate_dir="../slate-agent-kit"; fi; \
		if [ -z "$$slate_dir" ] && [ -x "../../tooling/install-mcp.sh" ]; then slate_dir="../.."; fi; \
		if [ -z "$$slate_dir" ]; then echo "Missing slate-agent-kit. Set SLATE_AGENT_KIT_DIR or SKIP_MCP=1."; exit 1; fi; \
		BIN_DIR="$(BIN_DIR)" KIMI_CODE_HOME="$(KIMI_CODE_HOME)" "$$slate_dir/tooling/install-mcp.sh" --configure-kimi; \
	fi

uninstall: ## Remove kit-signed files installed by make install and unregister the MCP plugin (user-owned custom files are preserved)
	@slate_dir=""; \
	if [ -n "$${SLATE_AGENT_KIT_DIR:-}" ] && [ -x "$${SLATE_AGENT_KIT_DIR}/tooling/install-mcp.sh" ]; then slate_dir="$$SLATE_AGENT_KIT_DIR"; fi; \
	if [ -z "$$slate_dir" ] && [ -x "../slate-agent-kit/tooling/install-mcp.sh" ]; then slate_dir="../slate-agent-kit"; fi; \
	if [ -z "$$slate_dir" ] && [ -x "../../tooling/install-mcp.sh" ]; then slate_dir="../.."; fi; \
	if [ -n "$$slate_dir" ]; then KIMI_CODE_HOME="$(KIMI_CODE_HOME)" "$$slate_dir/tooling/install-mcp.sh" --uninstall-kimi || true; \
	else echo "note: slate-agent-kit not found; remove the slate-agent-kit-mcp plugin manually if registered"; fi
	@if [ ! -f "$(MANIFEST)" ]; then echo "No manifest at $(MANIFEST)."; exit 0; fi
	@while IFS= read -r f; do \
		case "$$f" in "## "*) continue ;; esac; \
		if [ -d "$$f" ]; then \
			if head -8 "$$f/SKILL.md" 2>/dev/null | grep -Eq '<!-- (slate-agent-kit:common|$(CUSTOM_SIGNATURE)) -->'; then \
				rm -rf "$$f" && echo "  removed $$f"; \
			else \
				echo "  kept (unrecognized signature): $$f"; \
			fi; \
		elif [ -f "$$f" ]; then \
			if head -1 "$$f" | grep -q -- '-custom:'; then \
				echo "  kept (user-owned): $$f"; \
			elif head -1 "$$f" | grep -Eq '<!-- (slate-agent-kit:common|$(CUSTOM_SIGNATURE)) -->'; then \
				rm -f "$$f" && echo "  removed $$f"; \
			else \
				echo "  kept (unrecognized signature): $$f"; \
			fi; \
		fi; \
	done < "$(MANIFEST)"
	@rm -f "$(MANIFEST)"
	@echo "Uninstalled."

validate: ## Sanity-check generated files and Kimi-specific surface
	@fail=0; \
	test -f AGENTS.md || { echo "missing AGENTS.md"; fail=1; }; \
	for f in AGENTS.md $(RULE_FILES); do \
		head -20 "$$f" | grep -Eq '<!-- (slate-agent-kit:common|kimi-agent-kit)' || { echo "bad signature: $$f"; fail=1; }; \
	done; \
	for s in $(SKILL_NAMES); do \
		test -f "kimi-skills/$$s/SKILL.md" || { echo "missing skill $$s"; fail=1; }; \
	done; \
	test -f scripts/configure-prefs.sh || { echo "missing scripts/configure-prefs.sh"; fail=1; }; \
	test -f scripts/kimi-agent-kit--aside-prefs.md.tmpl || { echo "missing aside prefs template"; fail=1; }; \
	test -f scripts/kimi-agent-kit--dispatch-prefs.md.tmpl || { echo "missing dispatch prefs template"; fail=1; }; \
	grep -R -n "TodoList" kimi-rules/kimi-agent-kit--kimi-surface.md >/dev/null || { echo "missing Kimi TodoList rule"; fail=1; }; \
	grep -R -n "AgentSwarm" kimi-rules/kimi-agent-kit--kimi-surface.md kimi-rules/kimi-agent-kit--delegation.md >/dev/null || { echo "missing Kimi AgentSwarm binding"; fail=1; }; \
	grep -R -n "slate-agent-kit-mcp" kimi-rules/kimi-agent-kit--kimi-surface.md README.md >/dev/null || { echo "missing Kimi MCP plugin documentation"; fail=1; }; \
	! grep -R -n "workslate_task\\|CLAUDE.md\\|claude-rules" AGENTS.md kimi-rules kimi-skills >/dev/null || { echo "stale Claude-specific terms found"; fail=1; }; \
	exit $$fail
