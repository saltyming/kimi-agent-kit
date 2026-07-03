#!/bin/sh
set -e

REPO="${REPO:-saltyming/kimi-agent-kit}"
BRANCH="${BRANCH:-main}"
SLATE_REPO="${SLATE_REPO:-saltyming/slate-agent-kit}"
SLATE_BRANCH="${SLATE_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
KIMI_CODE_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
SKIP_MCP="${SKIP_MCP:-0}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

AGENTS_FILE="$KIMI_CODE_HOME/AGENTS.md"
RULES_DIR="$KIMI_CODE_HOME/rules"
SKILLS_DIR="$KIMI_CODE_HOME/skills"
MANIFEST="$KIMI_CODE_HOME/.kimi-code-agent-kit-manifest"

RULE_FILES="
kimi-agent-kit--kimi-surface.md
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

prompt_tty() {
    label="$1"
    default="$2"
    answer=""
    if [ -z "${SKIP_PROMPT:-}" ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
        printf "%s [%s]: " "$label" "$default" >/dev/tty 2>&1 || true
        read -r answer </dev/tty 2>/dev/null || true
    fi
    [ -n "$answer" ] || answer="$default"
    printf '%s' "$answer"
}

find_slate_dir() {
    if [ -n "${SLATE_AGENT_KIT_DIR:-}" ] && [ -x "$SLATE_AGENT_KIT_DIR/tooling/install-mcp.sh" ]; then
        printf '%s' "$SLATE_AGENT_KIT_DIR"
        return 0
    fi
    for candidate in "../slate-agent-kit" "../.."; do
        if [ -x "$candidate/tooling/install-mcp.sh" ]; then
            (CDPATH= cd -- "$candidate" && pwd)
            return 0
        fi
    done
    return 1
}

uninstall() {
    if slate_dir="$(find_slate_dir 2>/dev/null)"; then
        KIMI_CODE_HOME="$KIMI_CODE_HOME" "$slate_dir/tooling/install-mcp.sh" --uninstall-kimi || true
    else
        echo "note: slate-agent-kit not found; remove the slate-agent-kit-mcp plugin manually if registered"
    fi
    if [ ! -f "$MANIFEST" ]; then
        echo "No manifest at $MANIFEST. Nothing else to uninstall."
        exit 0
    fi
    # Signature-guarded: only kit-signed files are removed; user-owned
    # (-custom: signed, e.g. prefs) and unrecognized files are preserved.
    while IFS= read -r f; do
        case "$f" in "## "*) continue ;; esac
        if [ -d "$f" ]; then
            if head -5 "$f/SKILL.md" 2>/dev/null | grep -q 'slate-agent-kit:common.kimi-code-agent-kit'; then
                rm -rf "$f"
                echo "  removed $f"
            else
                echo "  kept (unrecognized signature): $f"
            fi
        elif [ -f "$f" ]; then
            if head -1 "$f" | grep -q -- '-custom:'; then
                echo "  kept (user-owned): $f"
            elif head -1 "$f" | grep -q 'slate-agent-kit:common.kimi-code-agent-kit'; then
                rm -f "$f"
                echo "  removed $f"
            else
                echo "  kept (unrecognized signature): $f"
            fi
        fi
    done < "$MANIFEST"
    rm -f "$MANIFEST"
    echo "Uninstalled kimi-agent-kit."
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --uninstall) uninstall ;;
        --skip-mcp) SKIP_MCP=1 ;;
        -h|--help)
            echo "Usage: $0 [--uninstall] [--skip-mcp]"
            echo "Env: KIMI_CODE_HOME, REPO, BRANCH, SLATE_AGENT_KIT_DIR, SKIP_MCP, BIN_DIR, CUSTOM_RULES_DIR, SKIP_PROMPT"
            exit 0
            ;;
    esac
done

echo "Installing kimi-agent-kit..."
echo "  KIMI_CODE_HOME: $KIMI_CODE_HOME"
echo "  AGENTS.md:  $AGENTS_FILE (manual + rules concatenated)"
echo "  Skills:     $SKILLS_DIR/palette-*"

CUSTOM_RULES_DIR="${CUSTOM_RULES_DIR:-}"
if [ -z "$CUSTOM_RULES_DIR" ] && [ -z "${SKIP_PROMPT:-}" ]; then
    echo ""
    echo "Optional: append additional *.md rule files into AGENTS.md"
    echo "(press Enter to skip)"
    CUSTOM_RULES_DIR="$(prompt_tty "Path to a directory of custom rule files" "")"
fi

mkdir -p "$KIMI_CODE_HOME" "$RULES_DIR" "$SKILLS_DIR"
echo "## install @ $(date -u +%FT%TZ 2>/dev/null || date)" > "$MANIFEST"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if [ -f "$AGENTS_FILE" ] && ! head -1 "$AGENTS_FILE" | grep -Fq '<!-- slate-agent-kit:common -->'; then
    bak="$AGENTS_FILE.bak-$(date -u +%Y%m%dT%H%M%SZ)"
    cp -p "$AGENTS_FILE" "$bak"
    echo "WARNING: existing $AGENTS_FILE is not managed by this kit; backed up to $bak"
    echo "## backup: $bak" >> "$MANIFEST"
fi

: > "$AGENTS_FILE"
first=1
fetch "$RAW_BASE/AGENTS.md" "$tmp_dir/AGENTS.md"
for f in AGENTS.md $RULE_FILES; do
    if [ "$first" -eq 0 ]; then
        printf '\n---\n\n' >> "$AGENTS_FILE"
    fi
    first=0
    if [ "$f" = "AGENTS.md" ]; then
        cat "$tmp_dir/AGENTS.md" >> "$AGENTS_FILE"
    else
        src="$tmp_dir/$f"
        fetch "$RAW_BASE/kimi-rules/$f" "$src"
        cat "$src" >> "$AGENTS_FILE"
        dest="$RULES_DIR/$f"
        cp "$src" "$dest"
        echo "$dest" >> "$MANIFEST"
        echo "  rule: $dest"
    fi
done
printf '\n' >> "$AGENTS_FILE"
echo "$AGENTS_FILE" >> "$MANIFEST"
echo "  wrote $AGENTS_FILE"

if [ -n "$CUSTOM_RULES_DIR" ] && [ -d "$CUSTOM_RULES_DIR" ]; then
    echo "Appending custom rules from $CUSTOM_RULES_DIR..."
    for src in "$CUSTOM_RULES_DIR"/*.md; do
        [ -f "$src" ] || continue
        {
            echo ""
            echo "---"
            echo ""
            cat "$src"
        } >> "$AGENTS_FILE"
        echo "  custom: $(basename "$src")"
    done
fi

for s in $SKILL_NAMES; do
    dest="$SKILLS_DIR/$s"
    rm -rf "$dest"
    mkdir -p "$dest"
    fetch "$RAW_BASE/kimi-skills/$s/SKILL.md" "$dest/SKILL.md"
    echo "$dest" >> "$MANIFEST"
    echo "  skill: $dest"
done

# Preference files (aside/dispatch) — generated next to the rules, read on
# demand; user-owned after generation (custom signature, uninstall keeps them).
prefs_dir="$tmp_dir/scripts"
mkdir -p "$prefs_dir"
fetch "$RAW_BASE/scripts/configure-prefs.sh" "$prefs_dir/configure-prefs.sh"
fetch "$RAW_BASE/scripts/kimi-agent-kit--aside-prefs.md.tmpl" "$prefs_dir/kimi-agent-kit--aside-prefs.md.tmpl"
fetch "$RAW_BASE/scripts/kimi-agent-kit--dispatch-prefs.md.tmpl" "$prefs_dir/kimi-agent-kit--dispatch-prefs.md.tmpl"
if [ -n "${SKIP_PROMPT:-}" ]; then
    PREFS_PROMPT=no
    export PREFS_PROMPT
fi
RULES_DIR="$RULES_DIR" MANIFEST="$MANIFEST" PREFIX="kimi-agent-kit" sh "$prefs_dir/configure-prefs.sh"

install_mcp() {
    [ "$SKIP_MCP" != "1" ] || {
        echo "Skipping MCP registration because SKIP_MCP=1."
        return 0
    }
    if slate_dir="$(find_slate_dir 2>/dev/null)"; then
        BIN_DIR="$BIN_DIR" KIMI_CODE_HOME="$KIMI_CODE_HOME" "$slate_dir/tooling/install-mcp.sh" --configure-kimi
        return 0
    fi
    command -v git >/dev/null 2>&1 || {
        echo "Error: git is required to fetch slate-agent-kit for MCP registration. Re-run with SKIP_MCP=1 to install rules only." >&2
        exit 1
    }
    slate_tmp="$tmp_dir/slate-agent-kit"
    git clone --depth=1 --branch "$SLATE_BRANCH" "https://github.com/$SLATE_REPO.git" "$slate_tmp"
    BIN_DIR="$BIN_DIR" KIMI_CODE_HOME="$KIMI_CODE_HOME" "$slate_tmp/tooling/install-mcp.sh" --configure-kimi
}

install_mcp

echo ""
echo "Installed kimi-agent-kit."
echo "Manifest: $MANIFEST"
