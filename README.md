# codmax + claudmax

Windows batch scripts to run **Codex CLI** and **Claude Code** backed by **MiniMax M2.7** instead of their default providers — without touching your existing `codex` and `claude` installs.

| Command | Tool | Model | Billing |
|---------|------|-------|---------|
| `codex` | Your existing Codex install | GPT-5.x | OpenAI |
| `codmax` | Codex CLI v0.57.0 (pinned) | MiniMax M2.7 | MiniMax |
| `claude` | Your existing Claude Code install | Claude Sonnet/Opus | Anthropic |
| `claudmax` | Claude Code v2.1.126 (isolated install) | MiniMax M2.7 | MiniMax |

Your API key is read from a local file at runtime — nothing is hardcoded in the scripts.

---

## Prerequisites

- Windows
- Node.js + npm
- A MiniMax API key from [platform.minimax.io](https://platform.minimax.io)
- Codex CLI installed globally: `npm install -g @openai/codex`
- Claude Code installed globally: `npm install -g @anthropic-ai/claude-code`

Create a credentials file anywhere you like. The scripts default to `%USERPROFILE%\.credentials\minimax.env`:

```
MINIMAX_API_KEY=your_key_here
```

If you store it elsewhere, edit the `CREDENTIALS_FILE` line at the top of each `.bat` file.

---

## codmax — Codex CLI with MiniMax

### Why Codex v0.57.0?

Codex CLI 0.125+ dropped support for `wire_api = "chat"` and now requires `wire_api = "responses"`. MiniMax only exposes a chat completions endpoint (`/v1/chat/completions`) — there is no `/v1/responses`. Version 0.57.0 is the last version that supports chat completions and is explicitly recommended in [MiniMax's documentation](https://platform.minimax.io/docs/token-plan/codex-cli).

The `codmax.bat` script pins to v0.57.0 via `npx` and overrides `wire_api` at runtime via `--config` flags, so the rest of your `~/.codex/config.toml` is unaffected.

### Setup

**1. Add the MiniMax profile to `~/.codex/config.toml`**

```toml
[profiles.m27]
model = "codex-MiniMax-M2.7"
model_provider = "minimax"

[model_providers.minimax]
name = "MiniMax Chat Completions API"
base_url = "https://api.minimax.io/v1"
env_key = "MINIMAX_API_KEY"
wire_api = "responses"
requires_openai_auth = false
request_max_retries = 4
stream_max_retries = 10
stream_idle_timeout_ms = 300000
```

> `wire_api = "responses"` here prevents your current `codex` from failing on startup. The `codmax` script overrides it to `"chat"` at runtime.

**2. Copy `codmax.bat` to a directory on your PATH**

`%APPDATA%\npm\` is already on PATH if you have npm installed globally.

### Known limitation

MiniMax M2.7 is a reasoning model. Via the chat completions wire format, `<think>` blocks appear as raw text in Codex sessions. This is a MiniMax/Codex compatibility gap, not configurable from this side.

---

## claudmax — Claude Code with MiniMax

MiniMax provides an Anthropic-compatible API endpoint at `https://api.minimax.io/anthropic`. Claude Code supports alternative providers via environment variables, so no config file changes are needed.

### Setup

**1. Install Claude Code to a dedicated directory**

```bat
npm install --prefix %USERPROFILE%\.claudmax-install @anthropic-ai/claude-code@2.1.126
```

This sits completely separately from your existing global `claude` install.

**2. (Optional but recommended) Apply the PII patch**

By default, Claude Code injects your Anthropic billing email into every API conversation. With a third-party provider like MiniMax, that email goes to MiniMax's servers. Apply [claude-pii-patcher](https://github.com/furuknap/claude-pii-patcher) to the isolated binary to prevent this:

```bat
:: Dry run first to confirm it finds the right bytes
node patch-claude.js --dryrun %USERPROFILE%\.claudmax-install\node_modules\@anthropic-ai\claude-code\bin\claude.exe

:: Apply the patch
node patch-claude.js %USERPROFILE%\.claudmax-install\node_modules\@anthropic-ai\claude-code\bin\claude.exe
```

**3. Copy `claudmax.bat` to the same PATH directory as `codmax.bat`**

---

## Updating

**codmax** is intentionally pinned to Codex v0.57.0. Do not update until MiniMax adds a responses-compatible endpoint.

**claudmax** is pinned to Claude Code v2.1.126. To update to a newer version:

```bat
npm install --prefix %USERPROFILE%\.claudmax-install @anthropic-ai\claude-code@<new-version>
```

Re-apply the PII patch after each update — new binaries are unpatched.

---

## References

- [MiniMax Codex CLI docs](https://platform.minimax.io/docs/token-plan/codex-cli)
- [MiniMax Claude Code docs](https://platform.minimax.io/docs/token-plan/claude-code)
- [claude-pii-patcher](https://github.com/furuknap/claude-pii-patcher)
- [Codex wire_api deprecation discussion](https://github.com/openai/codex/discussions/7782)
