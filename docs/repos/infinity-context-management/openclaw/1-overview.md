# OpenClaw

## Info

| Field           | Value                                  |
|-----------------|----------------------------------------|
| repo_link       | https://github.com/openclaw/openclaw   |
| created_at      | 2025-11-24                             |
| number_of_stars | 176499                                 |
| analysed_at     | 2026-02-08                             |

## What It Is

OpenClaw is an open-source, self-hosted personal AI assistant platform that runs on your own devices and connects to the messaging channels you already use. It provides a local-first Gateway (WebSocket control plane) that bridges AI models (Anthropic Claude, OpenAI GPT, Google Gemini, AWS Bedrock, local llama.cpp) with messaging platforms like WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Microsoft Teams, Matrix, Twitch, Nostr, and more. It includes companion apps for macOS, iOS, and Android, voice capabilities, browser automation, a visual Canvas workspace, and a skills/plugin system. Created by Peter Steinberger and the community. The project mascot is "Molty," a space lobster.

## Purpose

- Provide a single-user, local-first AI assistant that feels fast and always-on
- Unify all messaging channels under one AI-powered inbox via a WebSocket-based Gateway
- Let users run the assistant on their own hardware instead of depending on a cloud service
- Support multi-agent routing so different channels/accounts route to isolated agent workspaces
- Offer extensibility via a plugin/extension system and a skills platform (ClawHub registry)
- Maintain security by treating all inbound DMs as untrusted input with pairing-based access control

## Key Features

- Local-first Gateway -- single WebSocket control plane for sessions, channels, tools, events, and configuration (default port 18789)
- Multi-channel inbox -- WhatsApp (Baileys), Telegram (grammY), Slack (Bolt), Discord, Google Chat, Signal (signal-cli), BlueBubbles/iMessage, Microsoft Teams, Matrix, Zalo, Twitch, Nostr, LINE, Feishu/Lark, Nextcloud Talk, Mattermost, WebChat
- Multi-agent routing -- route inbound channels/accounts/peers to isolated agents with per-agent sessions and workspaces
- Voice wake + talk mode -- always-on speech recognition and continuous conversation on macOS, iOS, Android via ElevenLabs
- Live Canvas with A2UI -- agent-driven visual workspace that can be pushed/reset/snapshot
- Browser control -- managed Chrome/Chromium with CDP control, snapshots, actions, and uploads
- Companion apps -- macOS menu bar app, iOS node, Android node with camera, screen recording, location, and notifications
- Skills platform -- bundled, managed, and workspace skills with ClawHub registry for discovery and install
- Onboarding wizard -- `openclaw onboard` CLI wizard for guided setup
- ACP bridge -- Agent Client Protocol bridge for IDE integration (e.g., Zed editor)
- Cron jobs, webhooks, Gmail Pub/Sub triggers for automation
- Agent-to-agent communication via session tools
- Session model with compaction, pruning, and per-session configuration
- Security defaults -- DM pairing policy, allowlists, Docker sandboxing, `openclaw doctor` for auditing
- Tailscale Serve/Funnel integration for remote access
- Model failover and auth profile rotation (OAuth vs API keys)
- Docker, Nix, Fly.io, Render deployment options
- Plugin/extension SDK for adding new channels
- Control UI (Lit web components) and WebChat served from the Gateway
- Health checks, doctor migrations, logging, and operational tooling

## Core Concepts

1. Gateway           - central WebSocket-based control plane managing sessions, channels, tools, events, config, and cron. Runs locally (default port 18789). All clients (CLI, apps, WebChat) connect to it
2. Pi Agent Runtime  - the AI agent runtime that processes messages in RPC mode with tool streaming and block streaming. Connects to model providers (Anthropic, OpenAI) and executes tools
3. Sessions          - conversation state model. Each session has a key (e.g., `agent:main:main`), a transcript, and per-session settings (thinking level, verbosity, model, send policy). Supports compaction and pruning
4. Channels          - messaging platform integrations. Each channel has its own configuration, allowlists, group policies, and routing rules. Can be core (built-in) or extensions (plugins)
5. Nodes             - device-side capabilities exposed over the Gateway WebSocket. Provide camera, screen recording, location, notifications, and macOS `system.run`/`system.notify`
6. Skills            - modular capability packages extending the agent. Live in `~/.openclaw/workspace/skills/<skill>/SKILL.md`. Can be bundled, managed (ClawHub), or workspace-local
7. Multi-Agent       - route different inbound channels/accounts/peers to isolated agents, each with their own workspace, sessions, and configuration
8. Canvas + A2UI     - visual workspace surface the agent drives programmatically. A2UI (Agent-to-UI) pushes interactive content to companion apps
9. Pairing / DM Policy - security model for inbound messages. Unknown senders receive a pairing code and must be approved before the bot processes their messages
10. ACP Bridge       - Agent Client Protocol bridge exposing OpenClaw Gateway as an ACP agent over stdio/NDJSON for IDE integration
11. Workspace        - the agent working directory (`~/.openclaw/workspace`) containing injected prompt files (AGENTS.md, SOUL.md, TOOLS.md) and skills directories

## Possible Usages

- Personal AI assistant accessible across all messaging apps from a single self-hosted instance
- Voice-activated assistant on macOS/iOS/Android with always-on listening
- Browser automation agent navigating and interacting with web pages
- Automated workflows via cron jobs, webhooks, and Gmail Pub/Sub triggers
- Multi-agent setup where different channels route to specialized agents
- IDE copilot via the ACP bridge for editors like Zed
- Remote gateway on a Linux server with device nodes for local actions
- Group chat assistant in Slack/Discord/Teams with mention-based activation
- Media processing pipeline handling images, audio, and video with transcription hooks
- Home automation or system administration via `system.run` on macOS nodes
- Custom skill development using the plugin SDK and ClawHub registry

## Documentation Index

| File                     | Description                                                        |
|--------------------------|--------------------------------------------------------------------|
| 1-overview.md            | Project overview, features, core concepts, use cases               |
| 2-technical.md           | Tech stack, dependencies, installation, configuration              |
| 3-architecture.md        | Folder structure, entry points, design patterns, data flow diagrams|
| 4-code-patterns.md       | Coding style, testing, CI/CD, conventions                          |
| 5-usage-and-examples.md  | How to use, CLI commands, channel setup, workflows                 |
