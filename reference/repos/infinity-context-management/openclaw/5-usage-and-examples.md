# Usage and Examples

## Quick Start

```bash
# 1. Install
curl -fsSL https://openclaw.ai/install.sh | bash

# 2. Onboard (guided wizard)
openclaw onboard --install-daemon

# 3. Gateway starts automatically as a daemon
# Open the dashboard:
openclaw dashboard
```

The onboarding wizard walks through:
1. Model provider selection (Anthropic Claude, OpenAI, Google, local)
2. Auth setup (API key, OAuth/setup-token, subscription)
3. Channel selection (WhatsApp, Telegram, Slack, Discord, etc.)
4. Channel-specific configuration
5. Gateway token generation
6. Daemon installation (systemd on Linux, launchd on macOS)

## CLI Commands

| Command                    | Description                                |
|----------------------------|--------------------------------------------|
| openclaw onboard           | Guided setup wizard                        |
| openclaw gateway           | Start the gateway process                  |
| openclaw status            | Show gateway and channel status            |
| openclaw dashboard         | Open the Control UI in browser             |
| openclaw doctor            | Audit config, fix issues, migrations       |
| openclaw config get <key>  | Read a config value                        |
| openclaw config set <key>  | Write a config value                       |
| openclaw models status     | Show model auth status                     |
| openclaw models auth login | Run OAuth flow for a provider              |
| openclaw skill install     | Install a skill from ClawHub               |
| openclaw skill list        | List installed skills                      |
| openclaw security audit    | Run security audit (--deep for full)       |
| openclaw send              | Send a message to a channel                |
| openclaw session           | Manage sessions                            |

## Channel Setup

### Telegram

```bash
# During onboarding or manually:
openclaw onboard --channel telegram
```

Config:

```json5
{
  channels: {
    telegram: {
      botToken: "123456:ABCDEF",
    },
  },
}
```

Or via env: `TELEGRAM_BOT_TOKEN="123456:ABCDEF"`

### WhatsApp

```bash
openclaw onboard --channel whatsapp
# Scan QR code to link
```

Credentials stored at `~/.openclaw/credentials/whatsapp/<accountId>/creds.json`.

### Slack

Set `SLACK_BOT_TOKEN` + `SLACK_APP_TOKEN` or configure in `openclaw.json`:

```json5
{
  channels: {
    slack: {
      botToken: "xoxb-...",
      appToken: "xapp-...",
    },
  },
}
```

### Discord

Set `DISCORD_BOT_TOKEN` or:

```json5
{
  channels: {
    discord: {
      token: "1234abcd",
    },
  },
}
```

### Microsoft Teams

Configure a Teams app + Bot Framework, then:

```json5
{
  channels: {
    msteams: {
      appId: "...",
      appPassword: "...",
      allowFrom: ["user@example.com"],
    },
  },
}
```

### BlueBubbles (iMessage)

```json5
{
  channels: {
    bluebubbles: {
      serverUrl: "http://localhost:1234",
      password: "your-password",
      webhookPath: "/hooks/bluebubbles",
    },
  },
}
```

### WebChat

No separate config needed. Uses the Gateway WebSocket directly:
- Open `http://127.0.0.1:18789/` in browser
- Or use the macOS/iOS native app

## LLM Provider Setup

### Anthropic (Claude)

```bash
# Option A: API key
openclaw onboard --auth-choice anthropic-api-key

# Option B: Claude subscription (setup-token)
openclaw onboard --auth-choice setup-token
```

Config:

```json5
{
  agents: {
    defaults: {
      model: { primary: "anthropic/claude-opus-4-6" },
    },
  },
}
```

### OpenAI

```bash
openclaw onboard --auth-choice openai-api-key
# or
openclaw onboard --auth-choice openai-codex
```

Config:

```json5
{
  env: { OPENAI_API_KEY: "sk-..." },
  agents: {
    defaults: {
      model: { primary: "openai/gpt-5.1-codex" },
    },
  },
}
```

## Skills Usage

Skills extend the agent with specific capabilities. Each skill is a markdown file with instructions the agent follows.

```bash
# List bundled skills
openclaw skill list

# Install from ClawHub
openclaw skill install <skill-name>

# Skills auto-activate when their requirements are met
```

Bundled skills include: github, slack, weather, spotify-player, notion, obsidian, apple-notes, apple-reminders, trello, 1password, and 50+ more.

Skill format (SKILL.md):

```yaml
---
name: weather
description: Get current weather and forecasts
metadata:
  openclaw:
    requires: { bins: ["curl"] }
---
# Instructions for the agent...
```

## Automation

### Cron Jobs

```json5
{
  cron: {
    jobs: [
      {
        schedule: "0 9 * * *",
        message: "Check my calendar and summarize today",
        session: "agent:main:cron",
      },
    ],
  },
}
```

### Webhooks

Enable in config:

```json5
{
  hooks: {
    enabled: true,
    secret: "your-webhook-secret",
  },
}
```

Then POST to `http://localhost:18789/hooks/webhook`.

### Gmail Pub/Sub

Configure Gmail API credentials and Pub/Sub topic for email triggers. See docs at `docs.openclaw.ai/automation/gmail-pubsub`.

## Web Interface

The Control UI is a Lit web components dashboard served from the Gateway:

- Default URL: `http://127.0.0.1:18789/`
- Features: chat interface, config editor, session management, exec approvals, channel status
- Build: `pnpm ui:build`
- Access via Tailscale: configure `gateway.tailscale.mode: "serve"`

## Advanced Usage

### Multi-Agent Routing

Route different channels/contacts to isolated agents:

```json5
{
  agents: {
    main: { workspace: "~/.openclaw/workspace" },
    work: { workspace: "~/.openclaw/workspace-work" },
  },
  routing: {
    rules: [
      { channel: "slack", agent: "work" },
      { channel: "telegram", agent: "main" },
    ],
  },
}
```

### Remote Gateway

Run on a Linux server, connect device nodes from personal devices:

```json5
{
  gateway: {
    bind: "loopback",
    tailscale: { mode: "serve" },
  },
}
```

Connect from macOS/iOS apps via Tailscale or SSH tunnel.

### Docker Sandbox

Agent tool execution can be sandboxed in Docker:

```json5
{
  sandbox: {
    enabled: true,
    scope: "session",
    image: "openclaw-sandbox:bookworm-slim",
  },
}
```

### ACP Bridge (IDE Integration)

For Zed editor or other ACP-compatible IDEs:

```bash
openclaw acp
# Exposes Gateway as an ACP agent over stdio/NDJSON
```

### Voice (macOS/iOS/Android)

Configure ElevenLabs for voice:

```json5
{
  tts: {
    provider: "elevenlabs",
    voiceId: "your-voice-id",
  },
}
```

Wake word detection via Swabble (macOS).
