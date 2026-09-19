# Changelog

## 0.7.1 - 2026-09-19

**Comment preferences and interactive git preferences.** Ships alongside claude-agent-kit 12.0.1.

- **New: comment preferences.** A user-owned `kimi-agent-kit--comment-prefs.md` holds three values: whether new files get a header (`repository` or `structured`), the comment language, and doc comment coverage. Every value defaults to `repository`, so the repository's own convention decides and the file settles only what a repository leaves open. The precedence is the current-turn instruction, then a line under the file's "Repository overrides", then the repository's convention, then the file's value.
- **File header rule narrowed.** The execution loop's "File headers" paragraph became "File headers and comment style". Header presence and the structured layout (responsibility, boundary, invariants) moved into the comment prefs; "who calls it" was dropped from the layout because it goes stale as callers change. The rule keeps what a header leaves out (plan, phase, or ticket references, design deliberation, future intentions), the session-context rule, and adds: when you edit an existing header, keep its format and change only what your edit made untrue. The comment prefs are read once per session before creating a file or writing a comment, doc comment, or header, including in a file that is only being edited.
- **Git and comment prefs are configured interactively.** `configure-prefs.sh` and `configure-prefs.ps1` now prompt for the git values (default `unset`, so the agent still asks later for anything left unset) and the comment values, as they do for aside and dispatch. Unlike aside and dispatch, both files are edited in place: a reconfigure offers each current value as the default and rewrites only the value lines, so answers the agent recorded, repository overrides, and notes are kept. Env seeds `GIT_*` and `COMMENT_*` cover non-interactive runs. The shell version also handles a file with CRLF line endings.
- **Installers** fetch the new `kimi-agent-kit--comment-prefs.md.tmpl`; uninstall keeps the file (user-owned signature).

Verified in-session: `sh tooling/render-kit.sh` for all three kits and `sh tooling/validate.sh` (`validate: OK`; standing corpus claude 52.6 KB, codex 52.7 KB, kimi 51.6 KB); `configure-prefs.sh` under `sh` and `dash` and `configure-prefs.ps1` under `pwsh` in scratch directories (fresh install byte-identical to the templates; a rerun without reconfigure leaves files unchanged; `PREFS_RECONFIGURE=yes` without seeds changes nothing; seeds containing `| & \ $ /` are written literally; repository override lines survive; CRLF files are rewritten with CRLF kept); the interactive prompts driven through a pseudo-terminal; `make install` / `make uninstall` of each kit into scratch homes with `HOME` isolated (`SKIP_MCP=1`), and `make validate` for codex and kimi. Not run: the `curl | sh` and `irm | iex` installers, which fetch from GitHub `main`. No aside review, at the user's direction.

Patch bump, at the user's direction.

## 0.7.0 - 2026-09-19

**Subtraction release: blacklist-style rules, task-tracker rule removed, git workflow as user preferences.** The shared rule text was rewritten and cut (63.9 KB to 51.0 KB), and the git conventions became a user-owned prefs file. Ships alongside claude-agent-kit 12.0.0.

- **Form, not semantics.** The gates still require approval for the same actions. The rule text changed from lists of permitted cases ("Exactly three situations justify...", "The only legitimate skips...") to a default action, the named behaviors to avoid, where the rule applies, and the reason. This follows Anthropic's prompting guidance for the Claude 5 family (brief instructions over enumeration, reasons over bare commands, less emphasis) while staying explicit enough for models that read instructions literally (Sonnet 5, Opus 5). `HARD RULE`, `MUST`, and all-caps emphasis are gone, and so are the em-dashes and filler words the corpus itself carried.
- **One body per invariant.** Text that restated an invariant outside its ID anchor was removed (INV-STATE-1 in the execution loop, INV-GATE-3 in delegation and dispatch, the dispatch carve-out in four places, the INV-AUTH-1 precedence chain in palette, the kernel's "Quality Standards" and "Delegation (summary)", the full decision tree, the "After completion" checklist). A six-line quick reference remains.
- **Tool usage left to the tools.** Rule text that described how to call a tool was removed where the harness system prompt or the tool's own description already says it: aside's "Making the call" and "Cost", dispatch's "Supervising a run", the per-harness `decision-tree-delegation` insert.
- **Task-tracking rule removed.** The "populate the tracker before writing code" trigger, the `{{TASK_TRACKER}}` token, and the `execution-tracking` insert are gone in all three harnesses. Claude Code leaves `TaskCreate` / `TaskUpdate` / `TaskList` / `TodoWrite` out on the Claude 5 family unless opted in, and the rule was dropped everywhere to keep one corpus. palette's Tier B is now the user's approval alone.
- **New: INV-COMM-2, plain wording.** No stock metaphors ("load-bearing", "seam", "the crux", "surgical", "blast radius"), no sincerity or emphasis fillers ("genuinely", "honestly", "exactly", "precisely", "actually"), no "not just X but Y" framing, no opening a reply by agreeing with or praising the user. The example phrases were chosen from a frequency count over about 46,000 assistant output blocks in local session logs, not from public lists: "You're absolutely right" appeared once in 1.4M words, while `load-bearing`, `seam`, and the `genuinely` family were common.
- **New: file header rule** in the execution loop. A header states the file's responsibility in one sentence, then its boundary (what it owns, entry points, callers, split with neighbors), then file-wide invariants if any. No change history, plan or ticket references, design deliberation, or function lists, and nothing that is clear only inside the session that wrote it.
- **Git workflow became user preferences.** The standing `--no-gpg-sign` rule, the no-attribution rule, the Conventional Commits format, the PR body format, and branch naming moved out of the rules into a new user-owned `git-prefs` file. The kit sets no default. Every value installs as `unset`; before the first commit or PR that needs one, the agent asks and writes the answer into the file. When the repository's own convention differs from the preference, the agent asks which to follow there and records it under "Repository overrides". Installers create the file only when it is absent and never regenerate it.
- **Surface file trimmed.** The `TodoList` tracker bullet, the Delegation Binding section (it duplicated the delegation insert), and the "workslate is Claude-only" line were removed. Kept: the loading model and the Slate MCP plugin notes. The Kimi delegation insert now states which `Agent` types are read-only and which are write-capable, and that an `AgentSwarm` of coders is gated like any write-capable delegate.
- **Delegates and consultations.** A delegated agent may call the harness's native advisor. It does not call aside or dispatch unless the user explicitly approved that for the delegation.
- **Stale-term check.** `make check` now fails on any mention of `workslate`, not only `workslate_task`.
- **dispatch server: codex MCP tool calls now show in `dispatch_logs`.** codex records MCP and built-in function tools as `response_item/function_call` (name split into `namespace` + `name`, arguments as a JSON string) and `function_call_output` (a plain string, or an array of `input_text` blocks for MCP). `rollout.rs` rendered only `custom_tool_call`, so a run that called `mcp__aside__*` or any other MCP tool showed nothing under `tools`. Both records now render (`[tool] mcp__aside__aside_claude: {...}` under `tools`, the output under the opt-in `tool_results`); the duplicate `item_completed/McpToolCall` stays filtered. This closes the gap 11.2.1 / 0.6.1 listed under "Not changed".

Verified in-session: `sh tooling/render-kit.sh` for all three kits and `sh tooling/validate.sh` (`validate: OK`; standing corpus claude 71.9 KB to 52.1 KB, codex 65.0 to 51.9, kimi 63.9 to 51.0, and the hard budgets were lowered to 58 / 57 / 56 KB); `cargo fmt --check`, `cargo build`, `cargo test` (131 passed, including a new `curate_renders_function_calls` whose record shapes come from a real codex 0.154.0 rollout), and `cargo clippy --workspace --all-targets -- -D warnings` on stable 1.98.1. Not run: `dispatch_logs` end to end against a live codex task. No aside / advisor review this release, at the user's direction.

Minor bump: rule semantics are preserved, but a standing rule (task tracking) is removed and the git conventions stop applying until the prefs are set.

## 0.6.1 - 2026-09-05

**codex ≥ 0.153 rollout schema — `dispatch` and `aside` MCP servers (binary-only; rules unchanged).** codex-cli stopped writing `event_msg/user_message` / `agent_message` / `patch_apply_end` events (partially in 0.147.0, entirely from 0.153.4); prose and file changes now live only in `event_msg/item_completed` items (`UserMessage` / `AgentMessage` / `FileChange`). dispatch identified a fresh run's rollout by the nonce marker inside a `user_message` event, so every codex submit since then never associated: `dispatch_logs` reported `session_pending` forever (even after the run succeeded), `dispatch_steer` failed with `session_not_ready`, and the unassociated-run watchdog was armed against any run that wrote nothing within 30s.

- **harness-log**: new `codex::message_text` reads a user/agent message in either schema (the item content block type is `text` on UserMessage, `Text` on AgentMessage). `response_item/message` is deliberately not a message source — its `role:"user"` entries include harness-injected context (plugin lists, environment notes).
- **dispatch server**: `rollout::rollout_has_nonce` matches through `message_text` and now requires the FULL `[dispatch-task: <nonce>]` marker — a fallback-retry / watchdog-restart successor's nonce is `<base>-retryN` / `<base>-restart`, so the old bare-substring test could claim the successor's rollout for the original task. `rollout::curate` renders `item_completed` UserMessage / AgentMessage under `messages` and FileChange under `edits` (same `changes` map as `patch_apply_end`; a `failed` / `declined` status is surfaced verbatim, never shown as an applied edit); CommandExecution / McpToolCall items are skipped because their `custom_tool_call` / `function_call` records are unchanged. Prompt-echo elision covers the new schema. A `model_fallback` retry now persists its attempt nonce on the task row (`store::set_attempt_nonce`, clearing the prior association) so the retry's rollout validates instead of being rejected.
- **aside server**: `transcript/codex.rs` renders both schemas through the same helper.
- **Not changed**: `function_call` (MCP tool call) records are still not rendered under `tools` — a pre-existing gap.

Verified in-session: `cargo fmt --check`, `cargo build/test/clippy --workspace -- -D warnings` (stable 1.98.1), `sh tooling/validate.sh` (`validate: OK`); the release `dispatch` binary, driven over stdio against a real codex 0.153.4 task row the shipped binary could not associate, resolves the rollout and renders the curated timeline. Reviewed by `aside_codex` (gpt-6-astra, high reasoning — it caught the fallback-retry nonce regression) and built-in `advisor()`. slate commits 827ee55 + 58a347f; slate release v0.5.1.

Patch bump (server behavior fix; no rule or tool-surface change).

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
