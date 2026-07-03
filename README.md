# kimi-agent-kit

`kimi-agent-kit` is the Kimi Code CLI member of the Slate Agent Kit family. It installs a Kimi-focused `AGENTS.md`, detailed rules, and palette skills into `$KIMI_CODE_HOME` (default `~/.kimi-code`).

The common rule source lives in [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit). This repo keeps the Kimi-rendered form: `TodoList` task tracking, Kimi delegation surfaces, formal Korean communication, no-scope-reduction rules, palette, and shared `aside` / `dispatch` policy documents for environments where those MCP servers are installed.

## What's Inside

- `AGENTS.md` — Kimi operating manual rendered from Slate common rules.
- `kimi-rules/` — task execution, delegation, palette, git workflow, framework conventions, aside, and dispatch policy.
- `kimi-skills/palette-*` — pull-only palette helper skills.
- `install.sh` / `install.ps1` — user-scope installer for `$KIMI_CODE_HOME`.

`kimi-agent-kit` does not vendor the shared Rust MCP source. `aside` and `dispatch` live in `slate-agent-kit/shared/mcp-servers` so all harnesses use the same implementation.

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
- `SKIP_PROMPT=1` — suppress custom-rules prompt in `install.sh`.

## Relationship To Slate

This repo is intentionally a harness-specific rendered kit. To change shared behavior, edit `slate-agent-kit/shared` and render the Kimi adapter; do not hand-summarize rules here.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
