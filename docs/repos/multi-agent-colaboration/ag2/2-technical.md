# AG2 - Technical

## Tech Stack

| Property        | Value                                             |
|-----------------|---------------------------------------------------|
| Package name    | ag2 (primary), autogen (alias)                    |
| Version         | 0.11.0                                            |
| Python          | >=3.10, <3.14                                     |
| License         | Apache-2.0                                        |
| Build system    | hatchling                                         |
| Package manager | uv v0.8.15                                        |
| Linter          | ruff v0.12.12                                     |
| Formatter       | ruff                                              |
| Type checker    | mypy v1.17.1 (with pydantic.mypy plugin)          |
| Test framework  | pytest v8.4.2 + pytest-cov + pytest-asyncio       |
| Spell checker   | codespell v2.4.1                                  |
| Pre-commit      | pre-commit v4.3.0                                 |
| Docs            | mkdocs-material v9.6.19, mintlify                 |
| CI/CD           | GitHub Actions + Azure Pipelines (PoliCheck only) |
| Coverage        | codecov (threshold 1%, informational)             |

## Core Dependencies

| Package      | Version          |
|--------------|------------------|
| diskcache    | (unpinned)       |
| termcolor    | (unpinned)       |
| python-dotenv| (unpinned)       |
| tiktoken     | (unpinned)       |
| pydantic     | >=2.6.1,<3       |
| docker       | (unpinned)       |
| packaging    | (unpinned)       |
| httpx        | >=0.28.1,<1      |
| anyio        | >=3.0.0,<5.0.0   |

## Optional Dependency Groups

### LLM Providers

| Extra       | Key Package              | Version         |
|-------------|--------------------------|-----------------|
| openai      | openai                   | >=1.99.3        |
| anthropic   | anthropic[vertex]        | >=0.23.1        |
| gemini      | google-genai             | >=1.20.0,<2.0   |
| mistral     | mistralai                | >=1.0.1         |
| groq        | groq                     | >=0.9.0         |
| cohere      | cohere                   | >=5.13.5        |
| cerebras    | cerebras_cloud_sdk       | >=1.0.0         |
| together    | together                 | >=1.2           |
| ollama      | ollama                   | >=0.4.7         |
| bedrock     | boto3                    | >=1.34.149      |
| deepseek    | (uses openai extra)      | -               |

### Agent Features

| Extra              | Key Package                    | Version               |
|--------------------|--------------------------------|-----------------------|
| mcp                | mcp                            | >=1.11.0              |
| a2a                | a2a-sdk[http-server]           | >=0.3.11,<0.4         |
| ag-ui              | ag-ui-protocol                 | >=0.1.10,<0.2         |
| rag                | docling, selenium, chromadb    | various               |
| retrievechat       | chromadb, sentence_transformers| >=1.3.0,<1.4 / >=3.0.0|
| websurfer          | beautifulsoup4, markdownify    | (unpinned)            |
| browser-use        | browser-use                    | ==0.1.37              |
| crawl4ai           | crawl4ai                       | >=0.4.247,<0.8        |
| captainagent       | (uses autobuild + pandas)      | -                     |

### Code Execution

| Extra             | Key Package              | Version       |
|-------------------|--------------------------|---------------|
| jupyter-executor  | jupyter-kernel-gateway   | (unpinned)    |
| yepcode           | yepcode-run              | >=1.6.1       |
| remyx             | remyxai                  | >=0.2.0       |

### Interoperability

| Extra              | Key Package              | Version              |
|--------------------|--------------------------|----------------------|
| interop-crewai     | crewai[tools]            | >=0.76,<1            |
| interop-langchain  | langchain-community      | >=0.3.12,<1          |
| interop-pydantic-ai| pydantic-ai              | >=1.0.12             |

### Communication Agents

| Extra              | Key Package   | Version          |
|--------------------|---------------|------------------|
| commsagent-discord | discord.py    | >=2.4.0,<2.7     |
| commsagent-slack   | slack_sdk     | >=3.33.0,<3.40   |
| commsagent-telegram| telethon      | >=1.38.1,<2      |

### Storage/Cache

| Extra    | Key Package  | Version   |
|----------|--------------|-----------|
| redis    | redis        | (unpinned)|
| cosmosdb | azure-cosmos | >=4.2.0   |

## Installation

```bash
pip install ag2
pip install "ag2[openai]"
pip install "ag2[openai,gemini,anthropic]"
pip install "ag2[openai,mcp]"
pip install "ag2[openai,interop-langchain]"

# alias (backward-compatible with Microsoft AutoGen)
pip install autogen

# dev install
pip install -e ".[dev]"
pre-commit install
```

53 optional extras available. Multiple can be combined: `pip install "ag2[openai,mcp,a2a,browser-use]"`.

## Configuration

### OAI_CONFIG_LIST (primary LLM config)

```json
[
    {
        "model": "gpt-4o",
        "api_key": "<key>",
        "tags": ["gpt-4o", "tool", "vision"]
    },
    {
        "model": "<azure-deployment>",
        "api_key": "<key>",
        "base_url": "<endpoint>",
        "api_type": "azure",
        "api_version": "2025-01-01"
    }
]
```

### Environment Variables

| Variable             | Purpose                               |
|----------------------|---------------------------------------|
| OAI_CONFIG_LIST      | JSON list of LLM configs              |
| OPENAI_API_KEY       | OpenAI API key                        |
| ANTHROPIC_API_KEY    | Anthropic API key                     |
| GEMINI_API_KEY       | Google Gemini API key                 |
| TOGETHER_API_KEY     | Together AI API key                   |
| AZURE_OPENAI_API_KEY | Azure OpenAI key                      |
| AZURE_API_ENDPOINT   | Azure OpenAI endpoint URL             |
| AZURE_API_VERSION    | Azure API version                     |
| AUTOGEN_USE_DOCKER   | "False" disables Docker code execution|

## Build System

Dual-package publishing to PyPI:
1. `ag2`      - built with `uv build` (hatchling backend)
2. `autogen`  - built with setuptools (auto-generated from `setup.jinja`)

Both uploaded via twine in the `python-package.yml` workflow.

### Ruff Configuration

| Setting         | Value                                                  |
|-----------------|--------------------------------------------------------|
| line-length     | 120                                                    |
| target-version  | py310                                                  |
| preview         | enabled                                                |
| rules           | E, W, C90, N, I, F, ASYNC, C4, Q, SIM, RUF022, UP, D417|
| max complexity  | 10                                                     |

### mypy Configuration

| Setting         | Value                    |
|-----------------|--------------------------|
| python_version  | 3.10                     |
| strict          | true                     |
| plugins         | pydantic.mypy            |
| follow_imports  | silent                   |

## Dev Setup

Devcontainers available for Python 3.10-3.14 using Microsoft Python images. Features: zsh, node, git-lfs, quarto-cli. Setup installs `pip install -e ".[dev]"` and `pre-commit install`.

### Key Scripts

| Script                       | Purpose                                  |
|------------------------------|------------------------------------------|
| scripts/test.sh              | Base test runner with pytest             |
| scripts/test-skip-llm.sh     | Tests excluding LLM markers              |
| scripts/test-core-skip-llm.sh| Core tests without LLM, ignores contrib  |
| scripts/test-core-llm.sh     | LLM-tagged tests only                    |
| scripts/integration-test.sh  | Tests by dep + LLM marker combination    |
| scripts/lint.sh              | ruff check + ruff format                 |
| scripts/docs_build.sh        | Generate API refs + render notebooks     |
| scripts/docs_serve.sh        | Build and serve docs via mintlify        |
