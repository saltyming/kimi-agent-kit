# Changelog

## 0.4.2 - 2026-07-06

- **dispatch**: `dispatch_steer` now inherits the steered task's `allow_concurrent` by default and accepts an explicit override — fixes the case where a task in a directory with other concurrent runs could not be steered (`dir_busy` with no bypass; `allow_concurrent=false` re-enforces the guard). `allow_concurrent` is persisted on the task row via an additive, backward-compatible SQLite column (old DBs backfill to false).

## 0.4.1 - 2026-07-05

- **aside/dispatch recursion guard (security fix)**: closes a fork-bomb vector where a backend spawned by `aside`/`dispatch` — while still having them registered as MCP servers — could re-invoke them and spawn another backend without bound.
- **aside**: backends now carry no MCP server — codex is spawned with `exec --ignore-user-config` (auth still resolves from the codex home), alongside claude `--safe-mode` and copilot's read-only whitelist; plus a defense-in-depth `ASIDE_REENTRY_DEPTH` marker.
- **dispatch**: blocks dispatch→dispatch via a `DISPATCH_REENTRY_DEPTH` env marker (claude/opencode forward their env to MCP children) plus, for codex (which does not), `-c mcp_servers.dispatch.enabled=false`. `aside` stays reachable, so dispatch→aside is still allowed; new `reentrant` error code.

## 0.4.0 - 2026-07-05

- **aside**: new `aside_claude` backend; the server emits MCP `notifications/progress` on long calls so the client's per-tool-call timeout resets instead of aborting.
- **Install fixes**: `install.ps1` no longer installs to the wrong directory (missing `\` in `$env:USERPROFILE\.kimi-code`); `--uninstall` matches the real `slate-agent-kit:common` signature (was a no-op) and reads the line-6 skill signature; `install.sh` prompts for the required `DISPATCH_ROOTS`.
- **Windows (`install.ps1`)**: registers the MCP plugin natively (downloads the prebuilt `.zip` binaries + runs the shared `write-kimi-plugin.js`) and generates prefs — previously punted to POSIX.
- **Prefs / plugin**: the shared `configure-prefs.sh` is now interactive-first, injection-safe, all-knobs; a `configure-prefs.ps1` Windows twin + an extracted `write-kimi-plugin.js` (atomic write, corrupt-registry backup) are shared with slate.
- **README**: full rewrite to parity with the Claude kit — invariant kernel, palette, aside, dispatch, adapted to Kimi's surfaces.

## 0.3.0 - 2026-07-03

- **INV-QUALITY-1 — durable implementation** (rules-only release): new kernel invariant — every change must hold across the code's *declared operating envelope* (platforms, harnesses, input classes, callers, derived from repo evidence: docs, CI matrix, public APIs, tests, existing callers), not merely the case that triggered the work; fix causes, not symptoms; tests assert the contract, not the authoring machine's incidental representation. Woven into the execution loop (pre-coding envelope evidence, durability check, completion checklist), delegation prompt rules, and the dispatch spec-writing rule.

## 0.2.0 - 2026-07-03

- **Concat installer restored** (regression fix): Kimi Code loads only the single `$KIMI_CODE_HOME/AGENTS.md`, so `make install` / `install.sh` again concatenate the manual + all rule files into it (`---` separators) — the 0.1.0 kit copied rules into `$KIMI_CODE_HOME/rules/` where Kimi never reads them. A pre-existing unmanaged `AGENTS.md` is backed up to `.bak-<timestamp>` first.
- **Kimi surface rule** (`kimi-agent-kit--kimi-surface.md`, rendered from `slate-agent-kit/adapters/kimi/surface.md`): loading model, `TodoList` tracker binding, `Agent` / `AgentSwarm` delegation bindings (preserving the original Kimi split's semantics), skills, and the Slate MCP plugin contract with its plugin-prefixed tool names.
- **Rules re-rendered from the redesigned Slate corpus**: invariant kernel (INV-*/GATE-* IDs), execution loop, delegation loop with a Kimi-surfaces section, consolidated palette gate bindings.
- **Prefs machinery**: `scripts/configure-prefs.sh` + templates generate user-owned `kimi-agent-kit--{aside,dispatch}-prefs.md` in `$KIMI_CODE_HOME/rules/` (previously dangling references).
- **MCP hookup**: `make install` registers shared `aside`/`dispatch` as the local plugin `slate-agent-kit-mcp` via slate's `tooling/install-mcp.sh --configure-kimi` (`ASIDE_HARNESS=kimi`, native wire.jsonl transcript reading; `DISPATCH_ROOTS` required for dispatch containment); `install.sh` shallow-clones slate when no checkout is found; `SKIP_MCP=1` opts out.
- **Signature-guarded uninstall** (restored from the original split): only kit-signed files are removed; user-owned (`-custom:` signed) prefs and unrecognized files are preserved; the MCP plugin is unregistered via `--uninstall-kimi`.

## 0.1.0 - 2026-07-03

- Initial Kimi-specific split from the agent-kit family.
- Installs `AGENTS.md`, Kimi rules, and palette skills into `$KIMI_CODE_HOME`.
- Rules are rendered from `slate-agent-kit/shared` and keep full scope-integrity, verification, delegation, palette, aside, and dispatch policy.
