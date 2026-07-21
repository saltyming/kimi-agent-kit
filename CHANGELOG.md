# Changelog

## 0.6.0 - 2026-07-22

**`dispatch_wait` removed.** The `dispatch` MCP server's bounded long-poll tool is retired; supervise a run with `dispatch_status` (non-blocking snapshot + terminal result) and `dispatch_logs` (curated timeline). `dispatch_steer` / `dispatch_cancel` unaffected; the advertised dispatch surface drops 8 → 7 tools.

- **server**: `main.rs` drops the `dispatch_wait` method, its `wait_json` / `wait_log_tail` helpers, the `WAIT_*` constants, and the now-orphaned `preview_oneline` helper (only caller was `wait_json`; else `clippy -D warnings` fails). `params.rs` drops `WaitParams`. `get_info`'s SUPERVISION clause no longer names the tool. `rollout::window_with_limits` kept (backs `dispatch_logs` + its unit test); stale doc comment fixed.
- **rules**: `kimi-agent-kit--dispatch.md`'s "Ending a turn" HARD RULE is rewritten — `dispatch_status` is a non-blocking snapshot, so don't tight-poll: do other work and re-check, use the harness's own wait/scheduling, or tell the user. `get_info` / tool descriptions / decision-tree get a clean reference removal, no added guidance.
- CHANGELOG history left intact; no regression test added (user scope call).

Verified in-session: `cargo fmt --check`, `cargo build/test/clippy --workspace -- -D warnings`, `sh tooling/validate.sh` (`validate: OK`), post-render `grep` clean. Reviewed by `aside_codex` + `advisor()`.

Minor bump (public-MCP-tool-surface removal, shipped minor per user).

## 0.5.0 - 2026-07-17

**The subtraction release (shared corpus).** The shared rule sources halve: policy, gates, and trigger lists stay standing; operational mechanics move to just-in-time surfaces. Every INV-*/GATE-* definition and disambiguating boundary test is preserved.

- **aside / dispatch rules slimmed** — backend capability/redaction tables and tool-by-tool call mechanics now live in the MCP servers' own instructions and tool descriptions (loaded where the tools are used, not in every session).
- **dispatch server: observability + auto-restart.** `dispatch_status`/`dispatch_wait` report `child_process_alive`, `log_associated`, `log_last_write_age_seconds`; dead-owner rows reconcile at read time (conditional transition — a racing terminal write is never clobbered). A fresh codex submit whose log never associates within ~30s with no working-dir writes is killed and re-submitted once (`restart_of`/`restarted_as`; `DISPATCH_RESTART_UNASSOCIATED_SECS`, 0=off). Tool descriptions now state that a quiet log on a live process is inconclusive — judge liveness by the new fields, never by silence.
- **palette rules slimmed** — artifact schemas, RST house style, and scoring rubrics moved to `_palette/templates/*`, scaffolded by `palette-init` (which backfills templates for existing palette projects).
- **execution-loop rules condensed** — GATE-SCOPE-CONFIRM / GATE-DEVIATION / GATE-GIT keep every trigger and required sequence in tighter prose.
- **validate: standing-corpus byte budgets (hard)** — rendered-corpus regrowth past the per-harness ceiling fails the build.

## 0.4.4 - 2026-07-08

- **aside**: prompt hardened against leading-question anchoring bias — a leading/loaded question from the leader (e.g. "I fixed the race condition by adding a mutex — confirm this is correct") let the backend rubber-stamp the framing instead of independently checking the premise. `ROLE_FRAMING` now frames the backend's role as an independent second opinion; a new `INDEPENDENCE_REMINDER` is appended as the prompt's final section (after the question, not just folded into the top) so it isn't diluted by a large context/transcript block and lands with maximum salience right before the backend generates its answer. Guards against overcorrection — the backend still answers plainly when the premise holds and answers simple factual questions directly. New `compose_prompt` unit tests cover section ordering, the no-context/no-transcript case, and continuation-join substring checks on the new multi-line literals (none existed before).
- **rules**: `kimi-agent-kit--aside.md` gets a new "Question framing" section instructing the leader to phrase `question`/`context` as an assessment to verify, not a conclusion to confirm.

## 0.4.3 - 2026-07-06

- **dispatch**: poll responses no longer re-echo the whole submitted spec on every call. `dispatch_status` is compact by default — the accepted `spec`, rendered `prompt`, and `argv` move behind a new `include_spec` param (default false); terminal `result`/`error` still return. `dispatch_logs` / `dispatch_wait` collapse the backend's initial prompt echo (and opencode's duplicate `[opencode]` re-echo) to a one-line placeholder for fresh submits, matched by canonical content vs the stored prompt so a steered task's new instruction stays visible; bare `</think>` markers are dropped. Verified for codex/opencode/claude via synthetic fixtures.

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
