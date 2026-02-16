# multi-agent

Minimal multi-agent collaboration system. Multiple AI agents with different roles discuss a prompt in rounds until reaching a conclusion.

Zero frameworks. Just Python + LLM SDKs.

## How it works

1. Each agent is a markdown file defining its personality/role (= system prompt)
2. `config.json` maps agents to LLM providers and models
3. Agents take turns speaking in rounds, each seeing the full conversation so far
4. After all rounds, the last agent writes a final consolidated summary

```
Round 1:  PO speaks -> Architect sees PO -> Developer sees both -> QA sees all
Round 2:  PO refines -> Architect refines -> Developer refines -> QA refines
Summary:  QA consolidates everything into agreed decisions + deliverables + open questions
```

## Setup

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## Usage

```bash
.venv/bin/python run.py "design an authentication screen for a new system"
.venv/bin/python run.py --config path/to/config.json "build a REST API"
```

## Providers

| Provider     | Auth                          | Cost        |
|--------------|-------------------------------|-------------|
| claude-code  | Claude Max subscription OAuth | free (subscription) |
| anthropic    | ANTHROPIC_API_KEY env var     | pay per token |
| openai       | OPENAI_API_KEY env var        | pay per token |
| gemini       | GEMINI_API_KEY env var        | pay per token |

`claude-code` uses the `claude` CLI under the hood (`claude -p`), so it works with your Claude Max/Pro subscription without needing an API key. Requires [Claude Code](https://claude.com/claude-code) installed and authenticated.

## Config

`config.json`:

```json
{
  "max_rounds": 2,
  "agents": [
    { "name": "PO", "file": "agents/po.md", "provider": "claude-code", "model": "claude-sonnet-4-5-20250929" },
    { "name": "Architect", "file": "agents/architect.md", "provider": "claude-code", "model": "claude-sonnet-4-5-20250929" }
  ]
}
```

| Field      | Description                                           |
|------------|-------------------------------------------------------|
| max_rounds | how many full cycles all agents speak                 |
| agents     | ordered list; each agent speaks in sequence per round |
| name       | display name in output                                |
| file       | path to markdown file (relative to config.json)       |
| provider   | one of: claude-code, anthropic, openai, gemini        |
| model      | model ID for the provider                             |

You can mix providers - e.g. PO on Claude, Architect on GPT-4o, Developer on Gemini.

## Agent files

Each `.md` file in `agents/` is the raw system prompt. No frontmatter, no special syntax. Write whatever personality/instructions you want.

Example `agents/po.md`:

```
You are a Product Owner in a collaborative software team. Your role:

- Define user stories and acceptance criteria from the given requirement
- Prioritize features by user value and business impact
- Challenge assumptions and ask "why" questions to other team members
- Keep scope focused and achievable for a first iteration

When other agents have already spoken, build on their input. Agree, disagree, or refine.

Communication: concise, user-focused, uses bullet points. Max 300 words per response.
```

## File structure

```
multi-agent/
├── run.py              - CLI + orchestration + provider dispatch (single file)
├── config.json         - agent list, provider/model per agent, round count
├── requirements.txt    - anthropic, openai, google-genai
└── agents/
    ├── po.md           - Product Owner
    ├── architect.md    - Software Architect
    ├── developer.md    - Senior Developer
    └── qa.md           - QA Engineer
```

## Customization

- Add/remove agents: edit `config.json` and create/delete `.md` files
- Change personality: edit the agent's `.md` file
- Change model: update `model` field in `config.json`
- Change rounds: update `max_rounds` in `config.json`
- Mix providers: set different `provider` per agent
