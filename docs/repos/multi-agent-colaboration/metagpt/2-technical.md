# MetaGPT - Technical Details

## Tech Stack

| Component       | Technology                                    |
|-----------------|-----------------------------------------------|
| Language        | Python >=3.9, <3.12                           |
| Package manager | pip / setuptools                              |
| Config format   | YAML (pydantic-based, via custom YamlModel)   |
| Data validation | Pydantic >=2.5.3                              |
| CLI framework   | Typer 0.9.0 + Fire 0.4.0                      |
| Linting         | Ruff (v0.0.284), Black (23.3.0), isort        |
| Testing         | pytest + pytest-asyncio + pytest-cov          |
| Logging         | Loguru 0.6.0                                  |
| Runtime         | Python 3.9 (primary CI target)                |
| Node.js needed  | Node.js 20 (for mermaid-cli diagrams)         |
| Docker base     | nikolaik/python-nodejs:python3.9-nodejs20-slim|

Line length: 120. Ruff target: py39.

## Dependencies

### Core Dependencies

HTTP / Networking:

| Dependency        | Version   | Purpose                                    |
|-------------------|-----------|--------------------------------------------|
| aiohttp           | 3.8.6     | async HTTP client/server                   |
| httpx             | 0.28.1    | modern async HTTP client                   |
| httplib2          | ~0.22.0   | HTTP client library                        |
| curl-cffi         | ~0.7.0    | curl-based HTTP with TLS fingerprinting    |
| socksio           | ~1.0.0    | SOCKS proxy support                        |
| websocket-client  | ~1.8.0    | WebSocket client                           |
| websockets        | >=10,<12  | async WebSocket library                    |
| aiofiles          | 23.2.1    | async file I/O                             |

LLM Providers:

| Dependency                  | Version   | Purpose                        |
|-----------------------------|-----------|--------------------------------|
| openai                      | ~1.64.0   | OpenAI API client              |
| anthropic                   | 0.47.2    | Anthropic Claude API           |
| google-generativeai         | 0.4.1     | Google Gemini API              |
| zhipuai                     | ~2.1.5    | ZhipuAI (GLM) API              |
| qianfan                     | ~0.4.4    | Baidu Qianfan API              |
| dashscope                   | ~1.19.3   | Alibaba DashScope API          |
| spark_ai_python             | ~0.3.30   | iFlytek Spark API              |
| volcengine-python-sdk[ark]  | ~1.0.94   | Volcengine Ark API             |
| boto3                       | ~1.34.69  | AWS SDK (for Bedrock)          |
| semantic-kernel             | 0.4.3.dev0| Microsoft Semantic Kernel      |

Data / ML / Science:

| Dependency    | Version | Purpose                        |
|---------------|---------|--------------------------------|
| numpy         | ~1.26.4 | numerical computing            |
| pandas        | 2.1.1   | data manipulation              |
| scikit_learn  | 1.3.2   | machine learning toolkit       |
| tiktoken      | 0.7.0   | OpenAI tokenizer               |
| faiss_cpu     | 1.7.4   | vector similarity search       |
| rank-bm25     | 0.2.2   | BM25 ranking                   |
| jieba         | 0.42.1  | Chinese text segmentation      |

Document / Parsing:

| Dependency     | Version | Purpose                        |
|----------------|---------|--------------------------------|
| python_docx    | 0.8.11  | Word document generation       |
| openpyxl       | ~3.1.5  | Excel file handling            |
| beautifulsoup4 | 4.12.3  | HTML parsing                   |
| htmlmin        | -       | HTML minification              |
| Pillow         | -       | image processing               |

Code Analysis / AST:

| Dependency          | Version | Purpose                        |
|---------------------|---------|--------------------------------|
| libcst              | 1.0.1   | concrete syntax tree for Python|
| tree_sitter         | ~0.23.2 | incremental parsing            |
| tree_sitter_python  | ~0.23.2 | Python grammar for tree-sitter |
| grep-ast            | ~0.3.3  | AST-aware grep                 |
| unidiff             | 0.7.5   | unified diff parsing           |
| pylint              | ~3.0.3  | code analysis                  |

Infrastructure / Storage:

| Dependency        | Version | Purpose                        |
|-------------------|---------|--------------------------------|
| redis             | ~5.0.0  | Redis client                   |
| lancedb           | 0.4.0   | embedded vector database       |
| meilisearch       | 0.21.0  | search engine client           |
| qdrant-client     | 1.7.0   | Qdrant vector DB client        |
| gitpython         | 3.1.40  | Git repository operations      |
| gitignore-parser  | 0.1.9   | .gitignore parsing             |

Notebook / IPython:

| Dependency   | Version | Purpose                        |
|--------------|---------|--------------------------------|
| nbclient     | 0.9.0   | notebook execution             |
| nbformat     | 5.9.2   | notebook format handling       |
| ipython      | 8.17.2  | interactive Python             |
| ipykernel    | 6.27.1  | Jupyter kernel                 |
| ipywidgets   | 8.1.1   | Jupyter widgets                |

CLI / Config / Misc:

| Dependency        | Version | Purpose                        |
|-------------------|---------|--------------------------------|
| typer             | 0.9.0   | CLI framework                  |
| fire              | 0.4.0   | CLI from functions             |
| pydantic          | >=2.5.3 | data validation and settings   |
| PyYAML            | 6.0.1   | YAML parsing                   |
| loguru            | 0.6.0   | logging                        |
| rich              | 13.6.0  | terminal formatting            |
| tqdm              | 4.66.2  | progress bars                  |
| tenacity          | 8.2.3   | retry logic                    |
| networkx          | ~3.2.1  | graph data structures          |
| pygithub          | ~2.3    | GitHub API client              |
| playwright        | >=1.26  | browser automation             |
| gymnasium         | 0.29.1  | RL environments                |
| imap_tools        | 1.5.0   | email/IMAP operations          |

### Optional Dependency Groups

| Extra            | Key Packages                                                                     |
|------------------|----------------------------------------------------------------------------------|
| selenium         | selenium>4, webdriver_manager, beautifulsoup4                                    |
| search-google    | google-api-python-client==2.94.0                                                 |
| search-ddg       | duckduckgo-search~=4.1.1                                                         |
| rag              | llama-index-core, llama-index-embeddings-*, llama-index-vector-stores-*, docx2txt|
| pyppeteer        | pyppeteer>=1.0.2                                                                 |
| android_assistant| pyshine, opencv-python, protobuf, tensorflow, torch, transformers                |
| sela             | openml, xgboost, catboost, lightgbm                                              |

### Dev Dependencies

| Package        | Version | Purpose                        |
|----------------|---------|--------------------------------|
| pylint         | ~3.0.3  | code analysis                  |
| black          | ~23.3.0 | code formatting                |
| isort          | ~5.12.0 | import sorting                 |
| pre-commit     | ~3.6.0  | pre-commit hooks               |

### Test Dependencies

Aggregates all optional extras plus: pytest, pytest-asyncio, pytest-cov, pytest-mock, pytest-html, pytest-xdist, pytest-timeout, connexion[uvicorn], azure-cognitiveservices-speech, gradio, protobuf.

## Installation

### pip (stable)

```bash
pip install --upgrade metagpt
```

### From source (latest)

```bash
git clone https://github.com/geekan/MetaGPT.git
cd MetaGPT
pip install --upgrade -e .
```

### With extras

```bash
pip install -e .[rag]
pip install -e .[selenium]
pip install -e .[search-google]
pip install -e .[search-ddg]
pip install -e .[test]
pip install -e .[dev]
```

### Post-install (optional)

```bash
npm install -g @mermaid-js/mermaid-cli
pip install playwright && playwright install --with-deps chromium
```

### Docker

```bash
docker pull metagpt/metagpt:latest

docker run --rm --privileged \
  -v /opt/metagpt/config/config2.yaml:/app/metagpt/config/config2.yaml \
  -v /opt/metagpt/workspace:/app/metagpt/workspace \
  metagpt/metagpt:latest \
  metagpt "Write a cli snake game"
```

Build from source:

```bash
git clone https://github.com/geekan/MetaGPT.git
cd MetaGPT && docker build -t metagpt:custom .
```

### CLI entry point

```
metagpt=metagpt.software_company:app
```

Initialize config:

```bash
metagpt --init-config
```

Creates `~/.metagpt/config2.yaml`.

## Configuration

### Config file priority (latter overwrites former)

1. Environment variables
2. `<project_root>/config/config2.yaml` (repo-level)
3. `~/.metagpt/config2.yaml` (user-level)

### LLM Configuration (llm section)

| Field                | Type     | Default                   | Purpose                     |
|----------------------|----------|---------------------------|-----------------------------|
| api_type             | LLMType  | openai                    | LLM provider type           |
| api_key              | str      | sk-                       | API key                     |
| base_url             | str      | https://api.openai.com/v1 | API endpoint                |
| model                | str      | None                      | model name                  |
| api_version          | str      | None                      | API version (Azure)         |
| proxy                | str      | None                      | HTTP proxy                  |
| timeout              | int      | 600                       | request timeout             |
| max_token            | int      | 4096                      | max output tokens           |
| temperature          | float    | 0.0                       | sampling temperature        |
| top_p                | float    | 1.0                       | nucleus sampling            |
| stream               | bool     | True                      | stream responses            |
| reasoning            | bool     | False                     | enable reasoning mode       |
| reasoning_max_token  | int      | 4000                      | reasoning budget tokens     |
| context_length       | int      | None                      | max input tokens            |
| region_name          | str      | None                      | AWS region (Bedrock)        |

Supported LLM providers: openai, anthropic/claude, spark, zhipuai, fireworks, open_llm, gemini, azure, ollama, qianfan, dashscope, moonshot, mistral, yi, open_router, deepseek, siliconflow, openrouter_reasoning, bedrock, ark, llama_api.

### Per-Role LLM Configuration (roles section)

```yaml
roles:
  - role: "ProductManager"
    llm:
      api_type: "openai"
      model: "gpt-4-turbo"
      api_key: "..."
  - role: "Engineer"
    llm:
      api_type: "azure"
      model: "gpt-35-turbo"
```

### Other Configuration Sections

| Section   | Key Fields                                             |
|-----------|--------------------------------------------------------|
| embedding | api_type, api_key, base_url, model, dimensions         |
| search    | api_type (serpapi/serper/google/ddg/bing), api_key     |
| browser   | engine (playwright/selenium), browser_type             |
| mermaid   | engine (nodejs/ink/playwright/pyppeteer/none), path    |
| redis     | host, port, password, db                               |
| s3        | access_key, secret_key, endpoint, bucket               |
| exp_pool  | enabled, persist_path, retrieval_type (bm25/chroma)    |
| role_zero | enable_longterm_memory, memory_k, similarity_top_k     |

### Environment Variables

| Variable                         | Purpose                          |
|----------------------------------|----------------------------------|
| METAGPT_PROJECT_ROOT             | override project root directory  |
| PUPPETEER_SKIP_CHROMIUM_DOWNLOAD | skip Chromium download in Docker |
| PUPPETEER_EXECUTABLE_PATH        | custom Chrome path               |
| ALLOW_OPENAI_API_CALL            | 0 to disable real API in tests   |

### Config Examples Available

Located at `config/examples/`:

| File                            | Provider               |
|---------------------------------|------------------------|
| openai-gpt-4-turbo.yaml         | OpenAI GPT-4 Turbo     |
| openai-gpt-3.5-turbo.yaml       | OpenAI GPT-3.5 Turbo   |
| anthropic-claude-3-5-sonnet.yaml| Anthropic Claude 3.5   |
| google-gemini.yaml              | Google Gemini          |
| groq-llama3-70b.yaml            | Groq Llama3 70B        |
| aws-bedrock.yaml                | AWS Bedrock            |
| spark_lite.yaml                 | iFlytek Spark Lite     |
| huoshan_ark.yaml                | Volcengine Ark         |

## Supported Platforms

| OS            | Python | Supported |
|---------------|--------|-----------|
| macOS 13.x    | 3.9    | Yes       |
| Windows 11    | 3.9    | Yes       |
| Ubuntu 22.04  | 3.9    | Yes       |

## Docker Setup

Dockerfile details:
- Base: nikolaik/python-nodejs:python3.9-nodejs20-slim
- System packages: libgomp1, git, chromium, CJK/Thai fonts, libxss1
- Installs mermaid-cli globally via npm
- Sets CHROME_BIN=/usr/bin/chromium
- CMD: tail -f /dev/null (keeps container running)

DevContainer:
- Uses metagpt/metagpt:latest image
- docker-compose with bridge network
- VS Code extension: code-spell-checker
- postCreateCommand: installs mermaid-cli and pip install -e .
