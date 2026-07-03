# Changelog

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
