# Technical Details

## Tech Stack

| Layer    | Technology                                                     |
|----------|----------------------------------------------------------------|
| Backend  | Python 3.12, FastAPI, Uvicorn, WebSockets (wsproto)            |
| Frontend | Vue 3, Vite 7, Vue Router 4, Vue Flow (node graph editor)      |
| LLM      | OpenAI SDK, Google GenAI SDK (multi-provider via BASE_URL)     |
| Tooling  | MCP / FastMCP (Model Context Protocol), FAISS (vector search)  |
| Pkg Mgmt | uv (Python), npm (frontend)                                    |
| Build    | Hatchling (Python build backend), Vite (frontend bundler)      |
| Linting  | ESLint 9 + eslint-plugin-vue (frontend only)                   |
| License  | Apache-2.0                                                     |

## Python Version

Strictly Python 3.12.x only (`>=3.12,<3.13` in pyproject.toml). Build system: Hatchling. Package manager: uv (project itself is not installed as a package -- uv is used only for dependency management).

## Backend Dependencies

From pyproject.toml (canonical source):

| Package        | Version Constraint | Purpose                          |
|----------------|--------------------|----------------------------------|
| pyyaml         | (any)              | YAML parsing                     |
| openai         | (any)              | OpenAI API client                |
| google-genai   | >=1.52.0           | Google Gemini API client         |
| tenacity       | (any)              | Retry logic                      |
| mcp            | (any)              | Model Context Protocol           |
| fastmcp        | (any)              | FastMCP server/client            |
| faiss-cpu      | (any)              | Vector similarity search         |
| fastapi        | ==0.124.0          | Web framework (pinned)           |
| click          | >=8.1.8,<8.3       | CLI (pinned for compat)          |
| uvicorn        | (any)              | ASGI server                      |
| websockets     | (any)              | WebSocket support                |
| wsproto        | (any)              | WebSocket protocol impl          |
| pydantic       | ==2.12.5           | Data validation (pinned)         |
| requests       | (any)              | HTTP client                      |
| pytest         | (any)              | Testing                          |
| ddgs           | (any)              | DuckDuckGo search                |
| beautifulsoup4 | (any)              | HTML parsing                     |
| matplotlib     | (any)              | Charting/plotting                |
| networkx       | (any)              | Graph algorithms                 |
| cartopy        | (any)              | Geospatial mapping               |
| pandas         | >=2.3.3            | Data analysis                    |
| openpyxl       | >=3.1.2            | Excel file support               |
| numpy          | >=2.3.5            | Numerical computing              |
| seaborn        | >=0.13.2           | Statistical visualization        |
| chardet        | >=5.2.0            | Character encoding detection     |
| pygame         | >=2.6.1            | Game development                 |
| filelock       | >=3.20.1           | File locking                     |
| markdown       | >=3.10             | Markdown processing              |
| xhtml2pdf      | >=0.2.17           | HTML to PDF conversion           |

Additional dep in requirements.txt: `pysqlite3`.

## Frontend Dependencies

Production:

| Package              | Version  | Purpose                   |
|----------------------|----------|---------------------------|
| vue                  | ^3.5.22  | UI framework              |
| vue-router           | ^4.6.0   | Client-side routing       |
| @vue-flow/core       | ^1.47.0  | Node-based graph editor   |
| @vue-flow/background | ^1.3.2   | Vue Flow background grid  |
| @vue-flow/controls   | ^1.1.3   | Vue Flow zoom/pan controls|
| @vue-flow/minimap    | ^1.5.4   | Vue Flow minimap widget   |
| js-yaml              | ^4.1.0   | YAML parsing in browser   |
| markdown-it          | ^14.1.0  | Markdown rendering        |
| markdown-it-anchor   | ^9.2.0   | Markdown heading anchors  |

Dev:

| Package            | Version  | Purpose               |
|--------------------|----------|-----------------------|
| vite               | ^7.1.7   | Build tool/dev server |
| @vitejs/plugin-vue | ^6.0.1   | Vue SFC support       |
| eslint             | ^9.39.1  | Linter                |
| @eslint/js         | ^9.39.1  | ESLint JS config      |
| eslint-plugin-vue  | ^10.5.1  | Vue linting rules     |
| globals            | ^16.5.0  | Global variable defs  |

## Installation

Prerequisites: macOS / Linux / WSL / Windows, Python 3.12+, Node.js 18+, uv package manager.

```bash
uv sync
cd frontend && npm install
cp .env.example .env
```

Edit `.env` and set `API_KEY` and `BASE_URL` for your LLM provider.

## Configuration

### Environment Variables (.env)

| Variable           | Default/Example                                           | Required | Description                     |
|--------------------|-----------------------------------------------------------|----------|---------------------------------|
| BASE_URL           | https://api.openai.com/v1                                 | Yes      | LLM provider endpoint           |
| API_KEY            | sk-your-openai-api-key-here                               | Yes      | LLM provider API key            |
| SERPER_DEV_API_KEY | (commented out)                                           | No       | Serper.dev web search API key   |
| JINA_API_KEY       | (commented out)                                           | No       | Jina AI reading tool API key    |

Supported BASE_URL providers:

| Provider   | URL                                                            |
|------------|----------------------------------------------------------------|
| OpenAI     | https://api.openai.com/v1                                      |
| Gemini     | https://generativelanguage.googleapis.com/v1beta/openai/       |
| LM Studio  | http://localhost:1234/v1                                       |
| Ollama     | http://localhost:11434/v1                                      |

YAML workflows support `${VAR}` placeholders referencing .env variables.

### Server CLI Arguments

| Argument     | Default   | Description                      |
|--------------|-----------|----------------------------------|
| --host       | 0.0.0.0   | Server bind host                 |
| --port       | 8000      | Server port                      |
| --log-level  | info      | debug/info/warning/error/critical|
| --reload     | false     | Enable auto-reload for dev       |

## Build/Dev Commands

Makefile:

| Command              | Description                                     |
|----------------------|-------------------------------------------------|
| `make dev`           | Start both backend + frontend dev servers       |
| `make server`        | Start backend only (port 6400, --reload)        |
| `make client`        | Start frontend only (port 5173)                 |
| `make stop`          | Kill processes on ports 6400 and 5173           |
| `make sync`          | Sync Vue graphs from yaml_instance/ to server DB|
| `make validate-yamls`| Validate all YAML workflow files                |
| `make help`          | Show available commands                         |

Frontend npm scripts:

| Script            | Command        | Description              |
|-------------------|----------------|--------------------------|
| `npm run dev`     | `vite`         | Dev server (port 5173)   |
| `npm run build`   | `vite build`   | Production build         |
| `npm run preview` | `vite preview` | Preview production build |

## Docker

No Docker setup exists. No Dockerfile, docker-compose.yml, or .dockerignore in the repository.
