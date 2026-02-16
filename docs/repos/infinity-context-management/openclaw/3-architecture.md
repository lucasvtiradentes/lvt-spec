# Architecture

## High-Level Overview

OpenClaw is a multi-layer system: a central Gateway process manages all communication, with channel adapters for messaging platforms, an AI agent runtime for processing, and companion apps/nodes for device capabilities.

```
┌──────────────────────────────────────────────────────────────────┐
│                        User Devices                              │
│  ┌──────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────────┐    │
│  │ macOS    │  │  iOS    │  │ Android │  │ Browser (Lit UI) │    │
│  │ Menu Bar │  │  App    │  │  App    │  │ Control UI       │    │
│  └────┬─────┘  └────┬────┘  └────┬────┘  └───────┬──────────┘    │
│       │             │            │               │               │
└───────┼─────────────┼────────────┼───────────────┼───────────────┘
        │             │            │               │
        v             v            v               v
   ┌─────────────────────────────────────────────────────┐
   │              Gateway (WebSocket + HTTP)             │
   │                  Port 18789                         │
   │                                                     │
   │  ┌───────────┐  ┌───────────┐  ┌──────────────────┐ │
   │  │  Session  │  │  Router   │  │  Channel Mgr     │ │
   │  │  Manager  │  │           │  │                  │ │
   │  └─────┬─────┘  └─────┬─────┘  └────────┬─────────┘ │
   │        │              │                 │           │
   │        v              v                 v           │
   │  ┌───────────┐  ┌───────────┐  ┌──────────────────┐ │
   │  │ Agent     │  │ Multi-    │  │ Channel Plugins  │ │
   │  │ Runtime   │  │ Agent     │  │ (Core + Ext)     │ │
   │  │ (Pi)      │  │ Routing   │  │                  │ │
   │  └─────┬─────┘  └───────────┘  └────────┬─────────┘ │
   │        │                                │           │
   └────────┼────────────────────────────────┼───────────┘
            │                                │
            v                                v
   ┌─────────────────┐    ┌──────────────────────────────────────────┐
   │ LLM Providers   │    │          Messaging Platforms             │
   │                 │    │                                          │
   │ - Anthropic     │    │ - WhatsApp    - Telegram   - Slack       │
   │ - OpenAI        │    │ - Discord     - Signal     - Teams       │
   │ - Google        │    │ - Matrix      - iMessage   - Twitch      │
   │ - AWS Bedrock   │    │ - Nostr       - LINE       - Feishu      │
   │ - Local (llama) │    │ - Zalo        - Mattermost - Nextcloud   │
   └─────────────────┘    └──────────────────────────────────────────┘
```

## Folder Structure

```
openclaw/
├── src/                          - main TypeScript source
│   ├── acp/                      - Agent Client Protocol bridge
│   ├── agents/                   - multi-agent runtime and routing
│   ├── auto-reply/               - inbound message dispatch and reply logic
│   ├── browser/                  - browser automation (Playwright/CDP)
│   ├── canvas-host/              - Canvas + A2UI host
│   ├── channels/                 - channel registry and plugin system
│   │   └── plugins/              - channel plugin types, loading, config
│   ├── cli/                      - CLI entry point and argument parsing
│   ├── commands/                 - CLI command implementations
│   ├── compat/                   - backward compatibility helpers
│   ├── config/                   - config loading, validation, types, Zod schema
│   ├── cron/                     - cron job scheduling
│   ├── daemon/                   - daemon/background process management
│   ├── discord/                  - Discord channel (core)
│   ├── docs/                     - docs generation helpers
│   ├── gateway/                  - Gateway WebSocket server
│   ├── hooks/                    - hooks system (bundled, Gmail, workspace)
│   ├── imessage/                 - iMessage channel (core, legacy)
│   ├── infra/                    - infrastructure utilities
│   ├── line/                     - LINE channel (core)
│   ├── link-understanding/       - URL content extraction
│   ├── logging/                  - structured logging (tslog)
│   ├── macos/                    - macOS-specific integrations
│   ├── markdown/                 - markdown processing
│   ├── media/                    - media handling
│   ├── media-understanding/      - image/audio/video processing
│   ├── memory/                   - agent memory (vector search)
│   ├── node-host/                - device node host protocol
│   ├── pairing/                  - DM pairing security
│   ├── plugins/                  - plugin loader and SDK
│   ├── plugin-sdk/               - plugin SDK types/exports
│   ├── process/                  - process management (node-pty)
│   ├── providers/                - LLM model providers
│   ├── routing/                  - message routing logic
│   ├── scripts/                  - internal scripts
│   ├── security/                 - security audit and hardening
│   ├── sessions/                 - session management
│   ├── shared/                   - shared utilities
│   ├── signal/                   - Signal channel (core)
│   ├── slack/                    - Slack channel (core)
│   ├── telegram/                 - Telegram channel (core)
│   ├── terminal/                 - terminal I/O
│   ├── test-helpers/             - test helper utilities
│   ├── test-utils/               - test utility functions
│   ├── tts/                      - text-to-speech engine
│   ├── tui/                      - terminal UI (Pi TUI)
│   ├── types/                    - shared type definitions
│   ├── utils/                    - general utilities
│   ├── web/                      - web server and Control UI serving
│   ├── whatsapp/                 - WhatsApp channel (core)
│   └── wizard/                   - onboarding wizard
├── extensions/                   - channel/plugin extensions (pnpm workspace)
│   ├── bluebubbles/              - BlueBubbles (iMessage) channel
│   ├── discord/                  - Discord extension channel
│   ├── feishu/                   - Feishu/Lark channel
│   ├── matrix/                   - Matrix channel
│   ├── mattermost/               - Mattermost channel
│   ├── msteams/                  - Microsoft Teams channel
│   ├── nextcloud-talk/           - Nextcloud Talk channel
│   ├── nostr/                    - Nostr protocol channel
│   ├── twitch/                   - Twitch channel
│   ├── voice-call/               - Voice call (Twilio/Plivo/Telnyx)
│   ├── zalo/                     - Zalo OA channel
│   ├── memory-lancedb/           - LanceDB memory extension
│   ├── diagnostics-otel/         - OpenTelemetry diagnostics
│   ├── copilot-proxy/            - Copilot proxy extension
│   ├── lobster/                  - Lobster tool extension
│   └── ...                       - more extensions
├── skills/                       - bundled skill definitions (SKILL.md)
│   ├── github/                   - GitHub CLI skill
│   ├── slack/                    - Slack actions skill
│   ├── weather/                  - Weather skill
│   ├── spotify-player/           - Spotify skill
│   ├── notion/                   - Notion skill
│   ├── obsidian/                 - Obsidian skill
│   └── ...                       - 50+ bundled skills
├── ui/                           - Lit web components (Control UI)
│   ├── src/                      - UI source
│   └── public/                   - static assets
├── apps/                         - native companion apps
│   ├── macos/                    - macOS menu bar app (Swift)
│   ├── ios/                      - iOS app (Swift)
│   ├── android/                  - Android app (Kotlin)
│   └── shared/                   - shared Swift packages (OpenClawKit)
├── Swabble/                      - speech/wake word engine (Swift)
├── packages/                     - shared npm packages
│   ├── clawdbot/                 - ClawdBot package
│   └── moltbot/                  - MoltBot package
├── docs/                         - documentation (Mintlify)
├── scripts/                      - build/dev/deploy scripts
├── test/                         - test fixtures, helpers, mocks
├── vendor/                       - vendored dependencies (a2ui)
├── openclaw.mjs                  - main entry point
├── package.json                  - root package config
├── tsdown.config.ts              - build configuration
├── vitest.config.ts              - test configuration
└── Dockerfile                    - Docker build
```

## Entry Points

```
                  openclaw.mjs
                       |
                       v
                   src/cli/  ---->  src/commands/
                       |
            +----------+----------+
            v                     v
      Gateway Command       TUI / RPC Command
            |                     |
            v                     v
      src/gateway/            src/tui/
      - WS server             - Terminal UI
      - HTTP server
      - Channel init
      - Session mgr
      - Agent runtime
```

## Message Flow (Inbound)

```
┌───────────┐     ┌──────────────┐     ┌───────────────┐
│ Messaging │     │   Channel    │     │   Pairing /   │
│ Platform  │---->│   Adapter    │---->│   Allowlist   │
│ (e.g. WA) │     │   (monitor)  │     │   Check       │
└───────────┘     └──────────────┘     └───────┬───────┘
                                               │
                                               │
                                               v
                                     ┌─────────────────┐
                                     │ Auto-Reply      │
                                     │ Dispatch        │
                                     │                 │
                                     │ - finalize ctx  │
                                     │ - extract tags  │
                                     │ - route agent   │
                                     └────────┬────────┘
                                              │
                                              v
                                     ┌─────────────────┐
                                     │   Session       │
                                     │   Manager       │
                                     │                 │
                                     │ - load session  │
                                     │ - append msg    │
                                     └────────┬────────┘
                                              │
                                              v
                                     ┌─────────────────┐
                                     │ Pi Agent        │
                                     │ Runtime         │
                                     │                 │
                                     │ - LLM call      │
                                     │ - tool exec     │
                                     │ - stream reply  │
                                     └────────┬────────┘
                                              │
                                              v
                                     ┌─────────────────┐
                                     │   Reply         │
                                     │   Dispatcher    │
                                     │                 │
                                     │ - buffer blocks │
                                     │ - typing        │
                                     └────────┬────────┘
                                              │
                                              v
                                     ┌─────────────────┐
                                     │   Channel       │
                                     │   Outbound      │
                                     │   (send)        │
                                     └─────────────────┘
```

## Channel Plugin Architecture

```
┌──────────────────────────────────────────────────────┐
│                 ChannelPlugin Interface              │
│                                                      │
│  id: ChannelId                                       │
│  meta: ChannelMeta                                   │
│  capabilities: ChannelCapabilities                   │
│                                                      │
│  ┌──────────────────┐  ┌────────────────────────┐    │
│  │ ConfigAdapter    │  │ MessagingAdapter       │    │
│  │ - resolveAccount │  │ - send                 │    │
│  │ - getConfig      │  │ - sendMedia            │    │
│  └──────────────────┘  └────────────────────────┘    │
│                                                      │
│  ┌──────────────────┐  ┌────────────────────────┐    │
│  │ SetupAdapter     │  │ SecurityAdapter        │    │
│  │ - setup          │  │ - getDmPolicy          │    │
│  │ - probe          │  │ - getAllowFrom         │    │
│  └──────────────────┘  └────────────────────────┘    │
│                                                      │
│  ┌────────────────────┐  ┌────────────────────────┐  │
│  │ OnboardingAdapter  │  │ GatewayAdapter         │  │
│  │ - steps[]          │  │ - registerRoutes       │  │
│  │ - validate         │  │ - onStart/onStop       │  │
│  └────────────────────┘  └────────────────────────┘  │
│                                                      │
│  Optional: HeartbeatAdapter, GroupAdapter,           │
│  ThreadingAdapter, StreamingAdapter, OutboundAdapter │
└──────────────────────────────────────────────────────┘
```

Each extension in `extensions/` implements this `ChannelPlugin` contract and exports it via `openclaw.plugin.json`:

```json
{
  "name": "twitch",
  "version": "0.1.0",
  "entrypoint": "index.ts",
  "channels": ["twitch"]
}
```

## Skills System

```
┌──────────────────────────────────────────────────┐
│                 Skills Platform                  │
│                                                  │
│  ┌────────────────┐  ┌─────────────────────┐     │
│  │ Bundled Skills │  │  Managed Skills     │     │
│  │ (skills/)      │  │  (ClawHub registry) │     │
│  │                │  │                     │     │
│  │ - github       │  │  - installed via    │     │
│  │ - weather      │  │  openclaw skill     │     │
│  │ - slack        │  │  install <name>     │     │
│  │ - spotify      │  │                     │     │
│  │ - notion       │  │  Stored in:         │     │
│  │ - obsidian     │  │  ~/.openclaw/       │     │
│  │ - ...50+       │  │  workspace/skills/  │     │
│  └────────────────┘  └─────────────────────┘     │
│                                                  │
│  ┌──────────────────────────────────────────┐    │
│  │ Workspace Skills (local)                 │    │
│  │ ~/.openclaw/workspace/skills/<name>/     │    │
│  │ SKILL.md  (frontmatter + instructions)   │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  SKILL.md format:                                │
│  ---                                             │
│  name: weather                                   │
│  description: Get current weather                │
│  metadata:                                       │
│    openclaw:                                     │
│      requires: { bins: ["curl"] }                │
│      install: [...]                              │
│  ---                                             │
│  # Instructions for the agent...                 │
└──────────────────────────────────────────────────┘
```

## Module Dependency Graph

```
┌───────────┐
│  cli/     │
│  commands │
└────┬──────┘
     │
     v
┌──────────┐    ┌───────────┐    ┌──────────────┐
│ gateway/ │--->│ channels/ │--->│ extensions/  │
│          │    │ plugins/  │    │ (pnpm pkgs)  │
└────┬─────┘    └────┬──────┘    └──────────────┘
     │               │
     v               v
┌───────────┐    ┌────────────┐
│ sessions/ │    │ auto-reply │
└────┬──────┘    └─────┬──────┘
     │                 │
     v                 v
┌──────────┐    ┌────────────┐    ┌──────────┐
│ agents/  │--->│ providers/ │--->│ LLM APIs │
└────┬─────┘    └────────────┘    └──────────┘
     │
     v
┌──────────┐    ┌──────────┐    ┌──────────┐
│ config/  │    │ hooks/   │    │ memory/  │
└──────────┘    └──────────┘    └──────────┘
```

## Workspace Structure (pnpm)

```
pnpm-workspace.yaml:
  - .             (root - main openclaw package)
  - ui            (Lit web UI)
  - packages/*    (shared packages: clawdbot, moltbot)
  - extensions/*  (channel/plugin extensions)
```
