# CrewAI - Technical Details

## Tech Stack

| Component        | Technology                                              |
|------------------|---------------------------------------------------------|
| Language         | Python >=3.10, <3.14                                    |
| Build System     | Hatchling (hatchling.build)                             |
| Package Manager  | uv (workspace mode)                                     |
| Data Modeling    | Pydantic v2 (~2.11.9)                                   |
| CLI Framework    | Click (~8.1.7)                                          |
| Vector Store     | ChromaDB (~1.1.0) default, Qdrant optional              |
| Telemetry        | OpenTelemetry (api/sdk/exporter ~1.34.0)                |
| Default LLM      | OpenAI (gpt-4.1-mini default)                           |
| Linter           | Ruff (0.14.7)                                           |
| Type Checker     | mypy (1.19.0, strict mode)                              |
| Test Framework   | pytest (8.4.2) with xdist, asyncio, VCR                 |

## Repository Structure

The repository is a uv workspace monorepo with 4 packages:

| Package         | Path             | Version | Description                          |
|-----------------|------------------|---------|--------------------------------------|
| crewai          | lib/crewai/      | 1.9.3   | Core framework                       |
| crewai-tools    | lib/crewai-tools/| 1.9.3   | 70+ tools for agents                 |
| crewai-files    | lib/crewai-files/| 1.9.3   | File handling for multimodal inputs  |
| crewai-devtools | lib/devtools/    | 1.9.3   | Internal dev tools (private)         |

## Core Dependencies (crewai)

| Dependency                              | Version          | Purpose                          |
|-----------------------------------------|------------------|----------------------------------|
| pydantic                                | ~2.11.9          | Data modeling/validation         |
| openai                                  | >=1.83.0,<3      | OpenAI SDK                       |
| instructor                              | >=1.3.3          | Structured outputs from LLMs     |
| pdfplumber                              | ~0.11.4          | PDF text extraction              |
| regex                                   | ~2024.9.11       | Advanced regex                   |
| opentelemetry-api                       | ~1.34.0          | Telemetry API                    |
| opentelemetry-sdk                       | ~1.34.0          | Telemetry SDK                    |
| opentelemetry-exporter-otlp-proto-http  | ~1.34.0          | OTLP exporter                    |
| chromadb                                | ~1.1.0           | Vector store (memory/knowledge)  |
| tokenizers                              | ~0.20.3          | HuggingFace tokenization         |
| openpyxl                                | ~3.1.5           | Excel file support               |
| python-dotenv                           | ~1.1.1           | .env file loading                |
| pyjwt                                   | >=2.9.0,<3       | JWT handling                     |
| click                                   | ~8.1.7           | CLI framework                    |
| appdirs                                 | ~1.4.4           | Platform-specific directories    |
| jsonref                                 | ~1.1.0           | JSON reference resolution        |
| json-repair                             | ~0.25.2          | Malformed JSON repair            |
| tomli-w                                 | ~1.1.0           | TOML writing                     |
| tomli                                   | ~2.0.2           | TOML reading                     |
| json5                                   | ~0.10.0          | JSON5 parsing                    |
| portalocker                             | ~2.7.0           | File locking                     |
| pydantic-settings                       | ~2.10.1          | Settings management              |
| mcp                                     | ~1.23.1          | Model Context Protocol           |
| uv                                      | ~0.9.13          | Package manager (bundled)        |
| aiosqlite                               | ~0.21.0          | Async SQLite                     |

## Optional Dependencies (crewai)

| Extra              | Dependencies                                                      |
|--------------------|-------------------------------------------------------------------|
| tools              | crewai-tools==1.9.3                                               |
| embeddings         | tiktoken~=0.8.0                                                   |
| pandas             | pandas~=2.2.3                                                     |
| mem0               | mem0ai~=0.1.94                                                    |
| docling            | docling~=2.63.0                                                   |
| qdrant             | qdrant-client[fastembed]~=1.14.3                                  |
| aws                | boto3~=1.40.38, aiobotocore~=2.25.2                               |
| watson             | ibm-watsonx-ai~=1.3.39                                            |
| voyageai           | voyageai~=0.3.5                                                   |
| litellm            | litellm>=1.74.9,<3                                                |
| bedrock            | boto3~=1.40.45                                                    |
| google-genai       | google-genai~=1.49.0                                              |
| azure-ai-inference | azure-ai-inference~=1.0.0b9                                       |
| anthropic          | anthropic~=0.73.0                                                 |
| a2a                | a2a-sdk~=0.3.10, httpx-auth, httpx-sse, aiocache                  |
| file-processing    | crewai-files (workspace)                                          |

## crewai-tools Dependencies

| Dependency                | Version      | Purpose                          |
|---------------------------|--------------|----------------------------------|
| lancedb                   | ~0.5.4       | Vector DB for tools              |
| pytube                    | ~15.0.0      | YouTube video download           |
| requests                  | ~2.32.5      | HTTP requests                    |
| docker                    | ~7.1.0       | Docker SDK                       |
| crewai                    | ==1.9.3      | Core framework (pinned)          |
| tiktoken                  | ~0.8.0       | Token counting                   |
| beautifulsoup4            | ~4.13.4      | HTML parsing                     |
| python-docx               | ~1.2.0       | DOCX processing                  |
| youtube-transcript-api    | ~1.2.2       | YouTube transcript extraction    |
| pymupdf                   | ~1.26.6      | PDF processing                   |

27+ optional extra groups available for specific integrations (firecrawl, selenium, snowflake, mongodb, etc.)

## Installation

Standard:
```bash
pip install crewai
pip install 'crewai[tools]'
pip install 'crewai[tools,anthropic,bedrock]'
```

From source:
```bash
git clone https://github.com/crewAIInc/crewAI
cd crewAI
uv sync
```

Scaffolded project:
```bash
crewai create crew my-project
cd my-project
crewai install
crewai run
```

## LLM Providers

Native SDK providers (in lib/crewai/src/crewai/llms/providers/):

| Provider  | Model Prefix                                     | Extra Install              |
|-----------|--------------------------------------------------|----------------------------|
| OpenAI    | gpt-, o1-, o3-, o4-                              | (included by default)      |
| Anthropic | claude-                                          | crewai[anthropic]          |
| Gemini    | gemini/, gemini-                                 | crewai[google-genai]       |
| Azure     | azure/                                           | crewai[azure-ai-inference] |
| Bedrock   | bedrock/, anthropic., amazon., meta.             | crewai[bedrock]            |

Third-party via litellm:

| Provider   | Prefix      | Extra Install         |
|------------|-------------|-----------------------|
| Ollama     | ollama/     | (litellm or direct)   |
| Groq       | groq/       | crewai[litellm]       |
| NVIDIA NIM | nvidia_nim/ | crewai[litellm]       |
| Watson     | watson/     | crewai[watson]        |
| HuggingFace| huggingface/| crewai[litellm]       |
| Cerebras   | cerebras/   | crewai[litellm]       |
| SambaNova  | sambanova/  | crewai[litellm]       |

Three ways to configure:
1. Environment variable: `MODEL=gpt-4o` in .env
2. YAML: `llm: provider/model-id` in agents.yaml
3. Code: `LLM(model="provider/model-id", temperature=0.7)`

## Environment Variables

LLM Provider Keys:
- OPENAI_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY, AZURE_API_KEY
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
- AZURE_ENDPOINT, AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY, AZURE_API_VERSION

Search/Scraping Keys:
- SERPER_API_KEY, EXA_API_KEY, BRAVE_API_KEY, FIRECRAWL_API_KEY
- TAVILY_API_KEY, SERPAPI_API_KEY, SCRAPFLY_API_KEY, BROWSERBASE_API_KEY

CrewAI Platform:
- CREWAI_PLATFORM_INTEGRATION_TOKEN, CREWAI_PERSONAL_ACCESS_TOKEN
- CREWAI_TRACING_ENABLED (true/false)

Feature Flags:
- CREWAI_DISABLE_TELEMETRY (true/false)
- OTEL_SDK_DISABLED (true/false)
- CREWAI_TESTING (true/false)
- CREWAI_STORAGE_DIR (custom storage path)

## CLI Settings

Stored at `~/.config/crewai/settings.json`. Configurable via `crewai config`:

| Setting              | Default                    |
|----------------------|----------------------------|
| enterprise_base_url  | https://app.crewai.com     |
| oauth2_provider      | workos                     |
| oauth2_domain        | login.crewai.com           |

## Storage Locations

| Platform | Path                                            |
|----------|-------------------------------------------------|
| macOS    | ~/Library/Application Support/CrewAI/{project}/ |
| Linux    | ~/.local/share/CrewAI/{project}/                |
| Custom   | $CREWAI_STORAGE_DIR                             |
