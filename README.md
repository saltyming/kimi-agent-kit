# kimi-agent-kit

`kimi-agent-kit` is the Kimi Code CLI harness member of the Slate Agent Kit family. It installs a Kimi-focused `AGENTS.md`, detailed rules, and palette skills into `$KIMI_CODE_HOME` (default `~/.kimi-code`).

The common rule source lives in [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit). This repo keeps the Codex-rendered form: Kimi task tracking (`TodoList`), Kimi delegation constraints (`Agent` / `AgentSwarm`), formal Korean communication, no-scope-reduction rules, palette, and the shared `aside` / `dispatch` policy documents.

## What's Inside

- `AGENTS.md` — Kimi operating manual (invariant kernel) rendered from Slate common rules.
- `kimi-rules/` — the Codex surface binding (`--kimi-surface.md`: `TodoList`, `Agent` / `AgentSwarm`, skills, Slate MCP plugin), task execution, delegation, palette, git workflow, framework conventions, aside, and dispatch policy.
- `kimi-skills/palette-*` — pull-only palette helper skills.
- `scripts/` — prefs generator (`configure-prefs.sh` + templates) producing `$KIMI_CODE_HOME/rules/kimi-agent-kit--{aside,dispatch}-prefs.md`.
- `install.sh` / `install.ps1` — user-scope installer for `$CODEX_HOME`.

**Loading model:** Kimi Code loads only the single user-scope `$KIMI_CODE_HOME/AGENTS.md`, so the installer **concatenates** `AGENTS.md` + every rule file (with `---` separators) into that file. The copies in `$KIMI_CODE_HOME/rules/` are reference material; the prefs files there are read on demand and survive reinstall/uninstall (user-owned signature). A pre-existing `AGENTS.md` not managed by this kit is backed up to `AGENTS.md.bak-<timestamp>` before being replaced.

`kimi-agent-kit` does not vendor the shared Rust MCP source. `aside` and `dispatch` live in `slate-agent-kit/shared/mcp-servers` so all harnesses use the same implementation; `make install` registers them as the local Kimi plugin `slate-agent-kit-mcp` (`plugins/installed.json`) through slate's `tooling/install-mcp.sh --configure-kimi` (tool names are plugin-prefixed: `mcp__plugin-slate-agent-kit-mcp_aside__…`) (a slate checkout is discovered via `SLATE_AGENT_KIT_DIR` / sibling / parent, or shallow-cloned by `install.sh`). Pass `DISPATCH_ROOTS=/abs/workspace` at registration — **required for dispatch on Kimi**: the plugin runtime spawns MCP servers outside any project, so without roots every `dispatch_submit` returns `no_project_root`.

## Installation

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.ps1 | iex
```

From a clone:

```sh
make install
make validate
make uninstall
```

Environment:

- `KIMI_CODE_HOME` — install root, default `~/.kimi-code`.
- `CUSTOM_RULES_DIR` — optional directory of additional `*.md` rules appended to `AGENTS.md`.
- `SKIP_PROMPT=1` — suppress interactive prompts (custom rules, prefs) in `install.sh`.
- `SKIP_MCP=1` — install rules/skills only; skip MCP build + plugin registration.
- `SLATE_AGENT_KIT_DIR` — explicit slate checkout for MCP registration.
- `DISPATCH_ROOTS` — colon-separated workspace roots for dispatch containment.
- `ASIDE_*` / `DISPATCH_*` — non-interactive prefs values (see `scripts/configure-prefs.sh`).

## Relationship To Slate

This repo is intentionally a harness-specific rendered kit. To change shared behavior, edit `slate-agent-kit/shared` and render the Kimi adapter; do not hand-summarize rules here.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
