# Technical Details

## Tech Stack

| Layer        | Technology                                                  |
|--------------|-------------------------------------------------------------|
| Language     | TypeScript (strict, ES2023 target), Swift 6.2 (macOS/iOS)   |
| Runtime      | Node.js >= 22.12.0                                          |
| Module       | ESM (`"type": "module"`, NodeNext resolution)               |
| Package Mgr  | pnpm 10.23.0 (workspace support)                            |
| Build        | tsdown (powered by rolldown), tsc for plugin-sdk DTS        |
| Bundler      | rolldown 1.0.0-rc.3 (via tsdown)                            |
| Test         | Vitest 4.x (forks pool, v8 coverage)                        |
| Lint         | oxlint (type-aware), oxfmt, swiftlint, swiftformat          |
| UI           | Lit 3.x (web components, separate `ui/` workspace)          |
| Swift        | Swift Package Manager (swift-tools-version 6.2)             |
| Android      | Gradle (Kotlin/Java)                                        |
| Platforms    | macOS, iOS, Android, Linux, Windows (WSL2)                  |

## Key Dependencies

| Name                          | Version           | Purpose                                   |
|-------------------------------|-------------------|-------------------------------------------|
| hono                          | 4.11.8            | Web framework (gateway HTTP server)       |
| express                       | ^5.2.1            | Secondary web server / middleware         |
| ws                            | ^8.19.0           | WebSocket server/client (gateway WS)      |
| zod                           | ^4.3.6            | Runtime schema validation                 |
| @sinclair/typebox             | 0.34.48           | JSON Schema / type validation             |
| ajv                           | ^8.17.1           | JSON Schema validator                     |
| commander                     | ^14.0.3           | CLI framework                             |
| @clack/prompts                | ^1.0.0            | Interactive CLI prompts (onboarding)      |
| dotenv                        | ^17.2.4           | Environment variable loading              |
| grammy                        | ^1.39.3           | Telegram bot framework                    |
| @slack/bolt                   | ^4.6.0            | Slack bot framework                       |
| @buape/carbon                 | 0.0.0-beta-*      | Discord bot framework                     |
| @whiskeysockets/baileys       | 7.0.0-rc.9        | WhatsApp Web client                       |
| @line/bot-sdk                 | ^10.6.0           | LINE messaging channel                    |
| @larksuiteoapi/node-sdk       | ^1.58.0           | Feishu/Lark channel                       |
| @mariozechner/pi-agent-core   | 0.52.8            | Pi agent runtime core                     |
| @mariozechner/pi-ai           | 0.52.8            | Pi AI model abstraction                   |
| @mariozechner/pi-coding-agent | 0.52.8            | Pi coding agent module                    |
| @agentclientprotocol/sdk      | 0.14.1            | Agent Client Protocol SDK                 |
| @aws-sdk/client-bedrock       | ^3.985.0          | AWS Bedrock model provider                |
| playwright-core               | 1.58.2            | Browser automation                        |
| sharp                         | ^0.34.5           | Image processing (resize, convert)        |
| @lydell/node-pty              | 1.2.0-beta.3      | Pseudo-terminal (exec/process tools)      |
| sqlite-vec                    | 0.1.7-alpha.2     | SQLite vector search (memory)             |
| undici                        | ^7.21.0           | HTTP client                               |
| chokidar                      | ^5.0.0            | File system watcher                       |
| croner                        | ^10.0.1           | Cron scheduling engine                    |
| pdfjs-dist                    | ^5.4.624          | PDF parsing                               |
| @mozilla/readability          | ^0.6.0            | Article content extraction                |
| node-edge-tts                 | ^1.2.10           | Text-to-speech (Edge TTS)                 |
| yaml                          | ^2.8.2            | YAML parsing                              |

## Dev Dependencies

| Name                         | Version           | Purpose                                  |
|------------------------------|-------------------|------------------------------------------|
| typescript                   | ^5.9.3            | TypeScript compiler                      |
| @typescript/native-preview   | 7.0.0-dev.*       | Native TS compiler preview (tsgo)        |
| vitest                       | ^4.0.18           | Test runner                              |
| @vitest/coverage-v8          | ^4.0.18           | V8 code coverage provider                |
| tsdown                       | ^0.20.3           | Build tool                               |
| rolldown                     | 1.0.0-rc.3        | Bundler (Rust-based)                     |
| tsx                          | ^4.21.0           | TypeScript execution (dev loop)          |
| oxlint                       | ^1.43.0           | Linter (Rust-based, type-aware)          |
| oxfmt                        | 0.28.0            | Formatter (Rust-based)                   |
| lit                          | ^3.3.2            | Web components library (UI)              |
| ollama                       | ^0.6.3            | Ollama client (local model testing)      |
| @types/node                  | ^25.2.1           | Node.js type definitions                 |

## Installation

Method 1 - Installer script (recommended):

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

Method 2 - npm/pnpm:

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

Method 3 - From source:

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm ui:build
pnpm build
pnpm link --global
openclaw onboard --install-daemon
```

Method 4 - Docker:

```bash
./docker-setup.sh
# or manually:
docker build -t openclaw:local -f Dockerfile .
docker compose run --rm openclaw-cli onboard
docker compose up -d openclaw-gateway
```

Method 5 - Nix:

```bash
# Via nix-openclaw Home Manager module
# github:openclaw/nix-openclaw
```

Method 6 - Fly.io:

```bash
fly apps create my-openclaw
fly volumes create openclaw_data --size 1 --region iad
fly secrets set OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)
fly deploy
```

System requirements: Node >= 22.12.0, macOS / Linux / Windows (WSL2).

## Configuration

Config file: `~/.openclaw/openclaw.json` (JSON5 format).

Key sections: `agents`, `auth`, `bindings`, `channels`, `gateway`, `tools`, `plugins`, `meta`.

Key environment variables:

| Variable                     | Purpose                                             |
|------------------------------|-----------------------------------------------------|
| OPENCLAW_STATE_DIR           | Mutable state directory (default: `~/.openclaw`)    |
| OPENCLAW_CONFIG_PATH         | Config file path                                    |
| OPENCLAW_GATEWAY_TOKEN       | Gateway auth token (required for non-loopback bind) |
| OPENCLAW_GATEWAY_PORT        | Gateway port (default: 18789)                       |
| OPENCLAW_GATEWAY_BIND        | Bind mode: loopback / lan (default: loopback)       |
| OPENCLAW_BRIDGE_PORT         | Bridge port (default: 18790)                        |
| ANTHROPIC_API_KEY            | Anthropic API key                                   |
| OPENAI_API_KEY               | OpenAI API key                                      |
| GOOGLE_API_KEY               | Google API key                                      |
| DISCORD_BOT_TOKEN            | Discord bot token                                   |
| SLACK_BOT_TOKEN              | Slack bot token                                     |

State directories:

| Path                                           | Content                    |
|------------------------------------------------|----------------------------|
| ~/.openclaw/                                   | Main state directory       |
| ~/.openclaw/workspace/                         | Skills, prompts, memories  |
| ~/.openclaw/credentials/                       | Channel credentials        |
| ~/.openclaw/agents/<agentId>/sessions/         | Session data               |
| /tmp/openclaw/                                 | Logs                       |

## Build and Deployment

Docker:
- Base image: `node:22-bookworm`
- Runs as non-root `node` user (uid 1000)
- Default CMD: `node openclaw.mjs gateway --allow-unconfigured`
- Ports: 18789 (gateway), 18790 (bridge)

Fly.io (`fly.toml`):
- VM: shared-cpu-2x, 2048MB RAM
- Persistent volume at `/data`
- Force HTTPS, always running

Render (`render.yaml`):
- Docker runtime, starter plan
- Health check at `/health`
- 1GB persistent disk at `/data`

## Scripts

| Script            | Description                                         |
|-------------------|-----------------------------------------------------|
| build             | Full production build (tsdown + DTS + copy assets)  |
| dev               | Run in dev mode via tsx                             |
| check             | tsgo + lint + format                                |
| lint              | oxlint with type-aware rules                        |
| test              | Parallel test runner                                |
| test:coverage     | Vitest with v8 coverage                             |
| test:e2e          | E2E tests                                           |
| test:live         | Live model tests (requires OPENCLAW_LIVE_TEST=1)    |
| gateway:dev       | Dev gateway (skip channels)                         |
| gateway:watch     | Watch mode with auto-reload on TS changes           |
| ui:build          | Build the Lit web UI                                |
| ui:dev            | Dev mode for the web UI                             |
| docs:dev          | Local docs server (Mintlify)                        |
| openclaw          | Run any openclaw CLI command                        |
| tui               | Terminal UI                                         |
| ios:build         | Build iOS app                                       |
| android:run       | Build + install + launch Android debug              |
| mac:package       | Package macOS .app bundle                           |
