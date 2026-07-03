#!/bin/sh
set -e

REPO="${REPO:-saltyming/kimi-agent-kit}"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
KIMI_CODE_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"

AGENTS_FILE="$KIMI_CODE_HOME/AGENTS.md"
RULES_DIR="$KIMI_CODE_HOME/rules"
SKILLS_DIR="$KIMI_CODE_HOME/skills"
MANIFEST="$KIMI_CODE_HOME/.kimi-agent-kit-manifest"

RULE_FILES="
kimi-agent-kit--task-execution.md
kimi-agent-kit--palette.md
kimi-agent-kit--delegation.md
kimi-agent-kit--git-workflow.md
kimi-agent-kit--framework-conventions.md
kimi-agent-kit--aside.md
kimi-agent-kit--dispatch.md
"

SKILL_NAMES="
palette-init
palette-rules
palette-spec
palette-ui
palette-ux
"

fetch() {
    url="$1"
    dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        echo "Error: curl or wget required" >&2
        exit 1
    fi
}

uninstall() {
    if [ ! -f "$MANIFEST" ]; then
        echo "No manifest at $MANIFEST. Nothing to uninstall."
        exit 0
    fi
    while IFS= read -r f; do
        case "$f" in "## "*) continue ;; esac
        if [ -d "$f" ]; then
            rm -rf "$f"
            echo "  removed $f"
        elif [ -f "$f" ]; then
            rm -f "$f"
            echo "  removed $f"
        fi
    done < "$MANIFEST"
    rm -f "$MANIFEST"
    echo "Uninstalled."
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --uninstall) uninstall ;;
        -h|--help)
            echo "Usage: $0 [--uninstall]"
            echo "Env: KIMI_CODE_HOME, REPO, BRANCH"
            exit 0
            ;;
    esac
done

echo "Installing kimi-agent-kit..."
echo "  KIMI_CODE_HOME: $KIMI_CODE_HOME"

mkdir -p "$KIMI_CODE_HOME" "$RULES_DIR" "$SKILLS_DIR"
echo "## install @ $(date -u +%FT%TZ 2>/dev/null || date)" > "$MANIFEST"

fetch "$RAW_BASE/AGENTS.md" "$AGENTS_FILE"
echo "$AGENTS_FILE" >> "$MANIFEST"
echo "  wrote $AGENTS_FILE"

for f in $RULE_FILES; do
    dest="$RULES_DIR/$f"
    fetch "$RAW_BASE/kimi-rules/$f" "$dest"
    echo "$dest" >> "$MANIFEST"
    echo "  rule: $dest"
done

for s in $SKILL_NAMES; do
    dest="$SKILLS_DIR/$s"
    rm -rf "$dest"
    mkdir -p "$dest"
    fetch "$RAW_BASE/kimi-skills/$s/SKILL.md" "$dest/SKILL.md"
    echo "$dest" >> "$MANIFEST"
    echo "  skill: $dest"
done

echo ""
echo "Installed kimi-agent-kit."
echo "Manifest: $MANIFEST"
