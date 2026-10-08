# kimi-agent-kit

An operating manual and rule set for the Kimi Code CLI (`AGENTS.md` plus rule files), the palette document system with its skills, and three shared MCP servers: `aside` (second opinions from another model family), `dispatch` (asynchronous execution by a codex, opencode or claude backend) and `palette` (reads, checks and writes palette documents). One installer, `slate-setup`, installs all of it, registers the servers as a Kimi plugin, writes your preferences and sets the subagent default model.

This is kimi-agent-kit 0.11.2. Its rules, skills, templates and prefs templates are rendered from [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit), which also builds the servers and the installer; its release v0.10.2 provides the binaries. The Claude and Codex kits are rendered from the same source and differ only where the harness does.

## What's Inside

### Manual and rules

`AGENTS.md` is a set of numbered articles in six parts: each states one norm and the test that shows it was broken, is defined once and is cited by number (`§ 6`). The rule files hold only what the articles do not imply.

| Part | Articles | What it says |
|---|---|---|
| **I Direction** | § 1–6 | You set scope, priority, trade-offs and what counts as done; the agent neither expands nor shrinks the scope nor swaps in an approach it prefers. You decide whether a turn is discussion or execution; a next step written in a document is a proposal. The whole approved scope is delivered, and a completion criterion only you can authorize (a push, a merge) is raised before work begins. Documents advise; your approval authorizes. Deferred scope and any deviation from an approved plan come back to you first. |
| **II Autonomy** | § 7–9 | Under your direction the agent picks method, order and tools and judges whether consulting, dispatching or delegating is worth its cost; no article makes any of them mandatory on a condition. Consultation, dispatch and subagents each have a level. Changes hold for every platform and caller the code claims and fix the cause. |
| **III State** | § 10–13 | No rollback on the agent's own initiative; "undo" reverses this session's edits with file edits, not git; your uncommitted changes are left alone; destructive git runs only when you name the command and see everything it affects. |
| **IV Delegation** | § 14–15 | One writer per file; delegates are bound by every article and report instead of deviating. |
| **V Verification and reporting** | § 16–17 | Verify before claiming completion; report failures as failures; a completion report opens with what remains. |
| **VI Conduct** | § 18–21 | Formal register; plain wording without stock metaphors, fillers, flattery or self-praise; context usage is not a reason to stop; native memory holds only what has no other home (see `memory-triage` below). |

Kimi Code loads a single user-scope `$KIMI_CODE_HOME/AGENTS.md` that applies to every project, so the installer writes that file as the manual followed by every rule file and your custom rules, each separated by a `---` line. The copies in `$KIMI_CODE_HOME/rules/` are reference material. The rule files:

- `kimi-agent-kit--kimi-surface.md`: what differs in Kimi Code (see below).
- `kimi-agent-kit--task-execution.md`: the execution loop, undo and destructive git.
- `kimi-agent-kit--palette.md`: the palette document system.
- `kimi-agent-kit--delegation.md`: subagents and the other ways work leaves the session, with the Kimi delegation surfaces.
- `kimi-agent-kit--models.md`: which model and effort a delegate, a dispatch step or a consultation runs on, with the Kimi Code models.
- `kimi-agent-kit--git-workflow.md`: how your git preferences are read, asked for and recorded.
- `kimi-agent-kit--aside.md` and `kimi-agent-kit--dispatch.md`: when consultation and dispatch are worth using.

The manual and rule files come to about 28 KB; skills and prefs are outside `AGENTS.md` and load only when used.

**Kimi surface.** The servers reach Kimi Code as the local plugin `slate-agent-kit-mcp`, so tool names are plugin-prefixed and differ from the plain names other harnesses use, for example `mcp__plugin-slate-agent-kit-mcp_aside__aside_list` and `mcp__plugin-slate-agent-kit-mcp_palette__palette_status`. Skills are scanned natively from `$KIMI_CODE_HOME/skills`. If the plugin is not installed, the agent says the tool surface is missing and does not pretend a call was made.

### Action levels

Consultation (aside), dispatch and subagents spend your models, quota and time, so each has one level in its prefs file. Without a prefs file the level is `suggest`.

| Level | The agent |
|---|---|
| `on-request` | Uses the surface only when you ask. |
| `suggest` (default) | Proposes it in one line (what, where, how many, which model) and waits. |
| `auto` | Judges the value, uses it, and states in one line how many, which model and why. |

At every level the agent applies the same test first: could the result change a decision that is not yet made, is the user already doing that job, and is the cost in models, count, quota and time proportionate to what it can change. A current-turn instruction ("use dispatch", "no aside") outranks the level. A default model in the prefs applies unless you name another for the turn.

### palette

palette is a project's document system. It is on only in a project that contains `_palette/`; `palette-init` creates it. In a project without `_palette/` the agent leaves palette alone, apart from one line offering it for work that spans several increments.

| Family | Holds |
|---|---|
| backlog | Every work item and its status (`proposed`, `approved`, `in-phase-<N>`, `done`, `dropped`); the index of phases and deliverables. Status lives nowhere else. |
| phase | Goal, reason, assumptions and exit criteria of the active increment. |
| deliverable | One approved unit of the phase and its `Done when`. |
| state | Decisions not yet written into a record, questions that block the active phase, discrepancies between sources; one line each. |
| RFC / ADR | A decision, why it was made, and the evidence it relies on. |
| changeset / staging | Accepted edits to maintained documents that the source does not implement yet; staging is generated from them. |
| design / spec / principles / glossary | The maintained description of the system as the source implements it. |

- **Layout.** `_palette/layout.rst` places each family either `internal` (`_palette/`, your personal record, git-ignored and never committed) or at a project path (committed with the change it describes). You choose the placement in `palette-init`.
- **Documents advise, approval authorizes.** Where a document lives decides who sees it, not what it authorizes. palette never shrinks or defers approved scope; a narrower phase needs your approval and the naming of what moves to the backlog.
- **No development-stage records.** No document keeps progress narrative (what ran when, which model, which batch) or instructions to a later session; version control and session transcripts hold that history. An earlier session's view is a dated `Proposal`.
- **State is updated in place**, when a decision is made or a fact is verified, so a session that ends at any point leaves the documents true.
- **Resume.** A new session reads state within a budget, reports the lint result, where things stand, the open questions and a proposal, then waits for your direction.
- **Closing a phase** marks each item `done` with an outcome pointer or `dropped`, adds new problems as proposed items with your consent, and deletes the phase's files.
- Documents are reStructuredText in a small house-style subset. The templates ship with the kit (`$KIMI_CODE_HOME/skills/palette-init/templates/`) and through the palette server.

| Skill | Use |
|---|---|
| `palette-init` | Set up palette in a project (intake, placement of each family, seeded backlog), or move an earlier palette project. |
| `palette-resume` | Pick up a project at the start of a session. |
| `palette-state` | Keep backlog, phase, deliverable and state current: decisions, questions, discrepancies, item status, opening and closing a phase. |
| `palette-record` | Write an RFC or ADR with its evidence, maintain its changeset, promote the edits when the implementation lands. |
| `palette-spec`, `palette-ux`, `palette-ui`, `palette-rules` | Pull-only: run only when you ask. Technical contracts and choices; screens and navigation; visual language; the project's own conventions. |

The backlog, phase and deliverable cadence is inspired by [mano](https://github.com/ceceppa/mano) (MIT © 2026 ceceppa).

### memory-triage and the memory invariant

§ 21 puts native memory last: a fact goes to the code, a maintained document, a rule file or palette first. A correction that only concerns the current task is applied and not stored; a correction that is a rule is proposed to you as text for the project's instruction file or for this kit.

Kimi Code has no native memory, so the invariant applies when you ask the agent to remember something and to any memory file it writes. The `memory-triage` skill, shared with the other kits, proposes memory by memory whether to keep, promote, revise, merge or delete it (or that a rule already covers it), each with a reason, and changes nothing until you choose; it has no native Kimi memory to review.

### Subagents on Kimi Code

`Agent` with `subagent_type="explore"` or `"plan"` is read-only; `"coder"` is write-capable, and so is an `AgentSwarm` of coders. Subagents run on the `[secondary_model]` default set in the subagent prefs, or on the session's model when none is set. For one prompt over many inputs the agent prefers a single `AgentSwarm` with a tight prompt template to hand-rolled parallel `Agent` calls. It does not simulate a persistent team with background shells. The subagent level in the prefs decides whether the agent starts subagents on its own, proposes them, or waits for you.

### aside: consultation

Asks another model family for a read-only opinion through a locally installed CLI. Kimi Code has no built-in advisor, so aside is the second-opinion surface: `aside_codex` (OpenAI) and `aside_claude` (Anthropic); `aside_list` reports which are installed.

- **Transcript auto-forwarded, redacted.** `text` passes through verbatim; `tool_use`, `tool_result` and `thinking` become placeholders. 100 KB cap; `include_transcript=false` for decontextualised questions.
- **Read-only, non-interactive.** Each backend can read files and grep the workspace itself but cannot edit files or run shells.
- **Level and settings.** `kimi-agent-kit--aside-prefs.md` holds the level, the backend, and the model, reasoning effort and model fallback chain for that backend. A transient failure retries the same question on the next model in the chain, as one logical call. A current-turn instruction that names a backend ("ask codex", "no aside") outranks the level.
- **When it pays.** A decision that is still open: an architecture or public-contract choice other code will build on, concurrency or invariants, security-sensitive code, a diagnosis the evidence does not settle. Not while you are reviewing with the agent and waiting for its own answer, when the decision is made, or for a routine question. Every call spends third-party quota, so it is one focused question per call.

### dispatch: external execution

Hands a self-contained, write-capable execution step to a coding agent (codex, opencode or claude) that runs headless in the background. Where aside asks for an opinion, dispatch entrusts work.

- **Async submit, poll, cancel.** `dispatch_submit` returns a task id immediately and runs the backend detached (`codex exec`, or a short-lived local `opencode serve`); `dispatch_status` and `dispatch_list` track it; `dispatch_cancel` stops a run, or a whole `plan_id`, by killing its process group; `dispatch_backends` reports which backends are installed.
- **Watch and steer.** `dispatch_logs` shows a curated live timeline (codex rollout logs or dispatch-owned OpenCode event JSONL, noise filtered, paged by line range). `dispatch_steer` interrupts a run and resumes the same backend session with a new instruction, keeping its context and the files it already wrote, as a linked follow-up task.
- **Structured task spec.** Objective, target files, constraints and acceptance, plus free context, rendered deterministically into the backend prompt and stored for audit.
- **Persistent state.** A SQLite `dispatch.db`; statuses `queued`, `running`, `succeeded`, `failed`, `cancelled`, `interrupted`. At start, tasks stranded by a dead server are marked `interrupted` without touching a peer session's live runs.
- **Server-enforced guards.** The working directory must resolve inside a root you gave with `--roots` (see the note below); the `danger-full-access` sandbox is blocked unless the server is started with `DISPATCH_ALLOW_DANGER=1`; one active run per directory unless `allow_concurrent`. Codex uses its CLI sandbox; OpenCode uses its permission rules plus dispatch's directory guard, not an OS sandbox. Rejections return a structured `{error:{code,message}}`.
- **Level and settings.** `kimi-agent-kit--dispatch-prefs.md` holds the level, backend, model, reasoning effort and model fallback chain. Dispatch fits isolated mechanical edits, long verify-and-fix loops, large well-scoped sweeps and independent plan steps with clear target files and acceptance criteria. It does not fit an open product question, edits that overlap your own uncommitted changes, work that needs close interactive judgment, or anything that cannot be written as one self-contained spec.
- **No completion notification.** The agent checks a run later in the turn; when a turn ends with a run unfinished, it tells you the run is still going and that you need to ask it to check back.

> **Kimi needs a workspace root.** The Kimi plugin runtime starts servers in the plugin directory, not in your project, so without a workspace root every `dispatch_submit` and palette tool returns `no_project_root`. The install and configure steps ask for the root; pass `--roots /abs/workspace` to answer non-interactively, or run the configure step again to add one. The question accepts an empty answer only after a warning that dispatch and palette will then reject every project.

### palette server

Reads, checks and writes the palette documents of one project, so structure and cross-file consistency are kept by code. It embeds the document templates and derives its checks from them.

- **Read tools** (read-only annotation): `palette_status`, `palette_lint`, `palette_layout`, `palette_template`.
- **Write tools**: `palette_init`, `palette_layout_set`, `palette_backlog_add`, `palette_backlog_update`, `palette_phase_open`, `palette_deliverable_create`, `palette_deliverable_update`, `palette_phase_close`, `palette_state_record`, `palette_state_resolve`, `palette_record_create`, `palette_record_update`, `palette_changeset_edit`, `palette_changeset_promote`. Each takes an optional `dry_run` and returns the diff. Each changes every affected file or none: it writes temporary files and renames them into place, regenerates the indexes and staging it affects, lints what it touched, and refuses a result that would contain an error. It changes only the lines its operation concerns; a file it cannot parse is reported and never rewritten. Write tools stay under Kimi Code's approval.
- **Lint** (`P001` to `P017`) checks the RST subset, structure, identity, links, relations, changesets, generated files, status placement, development-stage wording, size budgets, layout, backlog consistency, the fields only the server writes, stray files, acceptance times and the structure of the `list-table` and `code-block` directives that records and maintained documents may use.
- **Project scope.** Every tool takes the project's absolute path, accepted only inside the server's project root or a root you gave with `--roots`.
- **Command line**: `palette check <project>` prints the findings and exits 1 on an error, for CI.

Without the server, the agent edits by hand from the templates, and the next resume's lint reports what drifted.

### Preferences

Five user-owned files in `$KIMI_CODE_HOME/rules/`. They are not part of the combined `AGENTS.md`, so you can edit them without reinstalling; the agent reads each the first time a session needs it (before consulting, dispatching or starting a subagent, before the first commit or PR, and before writing a file, comment or header).

| File | Sets | Installed default |
|---|---|---|
| `kimi-agent-kit--aside-prefs.md` | Level; backend (`codex` or `claude`); model, reasoning effort and model fallback for the chosen backend | `suggest`, `codex` |
| `kimi-agent-kit--dispatch-prefs.md` | Level; backend (`codex`, `opencode`, `claude`); model; reasoning effort; model fallback | `suggest`, `codex` |
| `kimi-agent-kit--subagent-prefs.md` | Level; default model; reasoning effort | `suggest`, harness default |
| `kimi-agent-kit--git-prefs.md` | Commit signing, model attribution, commit message format, PR body format, branch naming | `unset`: the agent asks at first need and records the answer |
| `kimi-agent-kit--comment-prefs.md` | File headers, comment language, doc comments | `repository`: the repository's own convention decides |

Each file starts with a `kimi-agent-kit-custom:` signature, so upgrade and uninstall keep it. A setting is a `##` heading followed by one bold value line; the installer changes only that value line and leaves your notes and any "Repository overrides" lines alone. You can edit a value by hand at any time. When a repository's own convention differs from a git or comment value, the agent asks which to follow there and records the answer.

The subagent default model and effort are also written to Kimi's own configuration, in `config.toml` under `[secondary_model]` as `default_model` and `default_effort` (`low`, `medium`, `high`, `xhigh` or `max`), only when set and after validation. The model is offered as a menu of the aliases in your `[models]` table, because an unknown alias makes Kimi's configuration invalid; when `[models]` has none, the step is skipped with an explanation. `force` is never set, and no pool entry is named `primary`. If you edit the model in the prefs file by hand, run the configure step again.

## Installation

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.sh | sh
# other commands and options go after "sh -s --":
curl -fsSL https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.sh | sh -s -- configure
curl -fsSL https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.sh | sh -s -- uninstall
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.ps1 | iex
# to pass a command or options, download the script and run it:
irm https://raw.githubusercontent.com/saltyming/kimi-agent-kit/main/install.ps1 -OutFile install.ps1
.\install.ps1 configure
```

The PowerShell script also accepts the earlier installers' switches: `-Uninstall`, `-SkipMcp` and `-DispatchRoots <paths>`.

The entry point downloads the prebuilt `slate-setup` for your platform from slate release v0.10.2, verifies its checksum, and runs it on the kit's payload. `slate-setup` performs every step, with the same code on Linux, macOS and Windows.

| Command | Does |
|---|---|
| `install` (default) | Full install or reinstall. |
| `configure` | Prefs, custom rules, native configuration and server registration only. |
| `uninstall` | Reverses what install recorded. `--uninstall` still works. |

| Option | Meaning |
|---|---|
| `--binaries prebuilt\|build\|skip` | `prebuilt` (default) downloads `aside`, `dispatch` and `palette`, and on Linux and macOS `agent-guard`, from the slate release, checked against `checksums.txt` (if release v0.10.2 does not exist it uses the latest and says so). `build` runs `cargo build --release` in `--slate-dir` and needs Rust. `skip` installs no binaries and registers no servers. `--skip-mcp` still works. |
| `--slate-dir <dir>` | The slate checkout to build from. |
| `--roots <paths>` | Workspace roots dispatch and palette may work in, as an OS path list. When it is not given, the `DISPATCH_ROOTS` environment variable is used. Kimi needs one (see above). |
| `--set <key>=<value>` | Pre-answers a prefs question; repeatable. Keys are `<file>.<key>`, for example `aside.level=auto` or `git.signing=no-gpg-sign`. |
| `--custom-rules <dir\|none>` | A folder of your own `*.md` rule files to install (or `none`). |
| `--yes` | Takes the current or default value for every question. |
| `--dry-run` | Prints the summary and exits. |
| `--home <dir>` | Kimi Code home. Default: `$KIMI_CODE_HOME`, else `~/.kimi-code`. |
| `--bin-dir <dir>` | Binary folder. Default: `~/.local/bin` (`%USERPROFILE%\.local\bin` on Windows). |
| `--ref <ref>` | `install.sh` only: the branch or tag of this repository to fetch for the one-line command. Default: `main`. |

### What a run does

Every run has the same shape: detect, ask, summarize and confirm, apply, report. Nothing changes before you confirm.

1. **Detect** the Kimi Code home, the installed kit version, your prefs files and leftovers of earlier installers.
2. **Ask**: binaries mode, workspace roots, each prefs file, and an optional folder of custom rules. Every answer is validated against the allowed values and asked again if it is invalid. Only relevant questions are asked (a backend's model and effort only for the backend you chose). An existing prefs file is kept unless you choose to reconfigure it. Prompts read from the terminal even when the script is piped; without a terminal, or with `--yes`, every question takes its current or default value.
3. **Summarize and confirm**: every file to write or back up, every registration, and every configuration key with its old and new value.
4. **Apply**: cleanup of leftovers from earlier installers (see Upgrading), binaries, `AGENTS.md` with the rules and skills, prefs files and custom rules, the plugin registration, and the `config.toml` edit.
5. **Report** the installed paths and that Kimi Code needs a restart.

What it writes: `AGENTS.md`, reference copies of the rules in `rules/`, `skills/`, `aside`, `dispatch` and `palette` in the binary folder (with `agent-guard`, the executable the servers start their backends through, beside them on Linux and macOS), the plugin folder `plugins/managed/slate-agent-kit-mcp/` (`kimi.plugin.json` and `SKILL.md`), the plugin's entry in `plugins/installed.json` (every other entry is kept; an unreadable registry is backed up before it is rebuilt), and a manifest, `.kimi-agent-kit-manifest.toml`, listing every file, backup, configuration key with its previous value, and registration. Kit-managed Markdown files start with `<!-- slate-agent-kit:common -->` or `<!-- kimi-agent-kit -->`. An existing `AGENTS.md` that is not kit-managed is copied to `AGENTS.md.bak-<UTC timestamp>` first. Each `*.md` in a custom rules folder is copied into `rules/` as `kimi-agent-kit--<name>.md`, signed as yours, and appears once in the combined `AGENTS.md`, which is regenerated from scratch on every install and configure; a file that would replace a kit-managed one is refused.

### Upgrading

Run the same install command over an earlier release (0.7.x). Beyond the files:

- **Prefs are migrated** after you confirm each file (without a terminal they are migrated). The old file is copied to `<file>.bak-<UTC timestamp>`; the new file starts from the current template, takes every value that has a new setting, and keeps your `Notes` and `Repository overrides` sections as they were.

  | Earlier value | Now |
  |---|---|
  | aside `Auto-call policy`: `conservative`, `preference-only` | Level `on-request` |
  | aside `Auto-call policy`: `proactive` | Level `auto` |
  | aside `Preferred third-party advisor` | Backend (`none` becomes `codex` with level `on-request`) |
  | dispatch policy `conservative`, `preference-only` | Level `on-request` |
  | dispatch `proactive` with approval mode `ask` | Level `suggest` |
  | dispatch `proactive` with approval mode `auto` | Level `auto` |
  | dispatch `Default granularity` | Dropped |
  | git and comment values | Carried over unchanged |
  | subagent prefs | New; created from the template |

- **Binaries and registrations** that earlier installers left in other places are removed.
- **Earlier scripts and environment seeds** (`configure-prefs`, the `ASIDE_*`, `DISPATCH_*`, `GIT_*` and `COMMENT_*` prefs seeds, `SKIP_MCP`) are replaced by `--set`, `--yes` and `--binaries skip`; `DISPATCH_ROOTS` still works as a default for `--roots`. Node.js is no longer needed.
- **An earlier palette project** (phase briefs, `stories/` with an index, `reviews.rst`, a `templates/` folder) is moved by `palette-init`, which proposes the move and applies only what you approve, after a backup of `_palette/` outside the repository: phase briefs become `phase.rst`, each story becomes a deliverable with plain `Done when` outcomes, the status in the story index moves to the backlog, unresolved items in the reviews become proposed backlog items with your consent, and `templates/` is removed because the templates now ship with the kit.

### Uninstall

`uninstall` removes the kit-managed files and folders the manifest lists after checking their signatures. It lists your `-custom:` files (prefs, custom rules) and keeps them unless you choose to remove them. It unregisters the servers and removes the plugin entry. It restores each configuration key it edited to its previous value, or removes the key if it did not exist, only while the current value is still the one the installer wrote; otherwise it reports the key and leaves it. A binary is removed only when no other kit's manifest lists it.

### From a clone

```sh
git clone https://github.com/saltyming/kimi-agent-kit && cd kimi-agent-kit
make install      # install from dist/
make configure    # prefs, custom rules, native configuration, server registration
make uninstall
make help
make install ARGS="--binaries build --slate-dir ../slate-agent-kit"   # options go in ARGS
```

### Requirements

- Linux, macOS or Windows. Rust is needed only for `--binaries build`.
- The backend CLIs, installed separately (the servers only wrap them): [codex](https://github.com/openai/codex), [Claude Code](https://claude.com/claude-code), and [OpenCode](https://opencode.ai/docs/cli/) for dispatch. `aside_list` and `dispatch_backends` report which are present; a missing one is reported as unavailable, not as an error.

## Kit Layout

```
dist/                  the payload slate-setup installs (rendered; do not edit)
  kit.toml             descriptor: kit, harness, versions, files, servers
  AGENTS.md            the manual
  rules/               rule files, in the order they are combined
  skills/              palette-* and memory-triage; palette templates in skills/palette-init/templates/
  prefs/               prefs templates
install.sh, install.ps1, Makefile   entry points (rendered): fetch slate-setup and run it
AGENTS.md              instructions for maintaining this repository (not installed)
README.md, CHANGELOG.md, LICENSE.md   maintained here
```

This repository is a rendered kit. To change the rules, skills, templates or entry points, edit the sources in slate-agent-kit (`shared/`, `adapters/kimi/`, `tooling/kit-scripts/`), render with `tooling/render-kit.sh kimi`, and run `tooling/validate.sh`; do not edit `dist/` or summarize rules by hand.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
