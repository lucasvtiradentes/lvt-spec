# AG2 - Code Patterns

## Coding Style

### Type Hints

Full type hints on all function signatures, using modern Python 3.10+ syntax:

```python
def register_for_llm(self, agent: "ConversableAgent") -> None:
    ...

def get_function_schema(
    f: Callable[..., Any],
    name: str | None = None,
    description: str = "",
) -> dict[str, Any]:
    ...
```

- `str | None` instead of `Optional[str]`
- `dict[str, Any]` instead of `Dict[str, Any]`
- `TYPE_CHECKING` guard for circular imports
- `TypeVar` for generic decorators

### Naming

- Classes: `PascalCase` (ConversableAgent, BaseEvent)
- Functions/methods: `snake_case` (register_for_llm, get_function_schema)
- Constants: `UPPER_SNAKE_CASE` (MAX_CONSECUTIVE_AUTO_REPLY)
- Private attributes: underscore prefix (self._name, self._func)
- Enforced by ruff rule `N` (pep8-naming)

### Docstrings

Google-style convention (enforced by ruff `D417`):

```python
def register_for_llm(self, agent: "ConversableAgent") -> None:
    """Registers the tool for use with a ConversableAgent's language model (LLM).

    Args:
        agent (ConversableAgent): The agent to which the tool will be registered.
    """
```

### License Header

Every `.py` file starts with:

```python
# Copyright (c) 2023 - 2025, AG2ai, Inc., AG2ai open-source projects maintainers and core contributors
#
# SPDX-License-Identifier: Apache-2.0
```

Files derived from Microsoft AutoGen also carry MIT attribution. Enforced by pre-commit hook.

### Module Export Pattern

Uses `@export_module("autogen.tools")` decorator to mark public API surface. Classes defined in deep internal modules get exported to simpler public paths.

```python
@export_module("autogen")
class SenderRequiredError(Exception):
    ...
```

### Formatting

- Line length: 120 characters
- Ruff formatter with `docstring-code-format = true`
- isort integrated into ruff (case-sensitive)
- Target: Python 3.10

## Testing

### Framework

- pytest 8.4.2 with pytest-cov 6.3.0, pytest-asyncio 1.1.0
- dirty-equals 0.9.0, freezegun 1.5.5
- Coverage: `--cov=autogen --cov-append --cov-branch --cov-report=xml`

### Organization

Tests mirror source structure: `test/agentchat/`, `test/tools/`, `test/oai/`, etc.

Two styles coexist:
- Functional:         `def test_conversable_agent_name(...)`
- Class-based:        `class TestTool:` with `@pytest.fixture(autouse=True)`
- Parametrized tests: `@pytest.mark.parametrize("name", [...])`

### Fixtures (conftest.py)

- `mock` / `async_mock` for MagicMock/AsyncMock
- `user_proxy` with `human_input_mode="NEVER"`, `code_execution_config=False`
- Credential fixtures for every LLM provider (gpt-4o-mini, gemini-flash, claude-sonnet, deepseek, etc.)
- `mock_credentials` for unit tests not calling real APIs
- Credential resolution: env vars (CI) -> OAI_CONFIG_LIST file (local) -> single env var (legacy)

### Markers

30+ custom markers in pyproject.toml:

| Category          | Markers                                                           |
|-------------------|-------------------------------------------------------------------|
| LLM providers     | openai, gemini, anthropic, deepseek, ollama, bedrock, cerebras    |
| Optional deps     | redis, docker, docs, rag, jupyter_executor, mcp, interop, etc.    |
| Special           | conda (excluded by default), aux_neg_flag, all                    |

The `aux_neg_flag` pattern enables selective execution: tests without it always run; tests with it only run when their specific LLM marker is selected.

### Test Utilities (test/utils.py)

```python
@suppress(exception=Exception, retries=3, timeout=60)
def test_flaky_api_call():
    ...
```

- Retries flaky tests with sleep between retries
- Calls `pytest.xfail()` on exhaustion
- Works for both sync and async

### Secret Sanitization (test/credentials.py)

`Secrets` class patches pytest terminal output to replace any substring matching a registered API key.

### Cross-SDK Safety

`get_safe_api_types_from_test_context()` walks the call stack to find pytest markers and filters config lists. A test marked `@pytest.mark.openai` only gets openai/azure types, never google or anthropic.

## CI/CD Pipeline

### Key Workflows

| Workflow           | Trigger        | Purpose                                                  |
|--------------------|----------------|----------------------------------------------------------|
| pr-checks          | PR, merge      | pre-commit, type-check (3 OS), core tests                |
| core-test          | daily cron     | 3 OS x 4 Python (3.10-3.13), no LLM                      |
| core-llm-test      | weekly cron    | per-LLM tests (openai, gemini, anthropic, deepseek, etc.)|
| contrib-test       | daily cron     | contrib tests without LLM (RetrieveChat, Swarm, etc.)    |
| contrib-llm-test   | weekly cron    | contrib tests with real API keys                         |
| integration-test   | weekly cron    | optional-deps x LLMs matrix                              |
| type-check         | daily cron     | mypy across 4 Python x ~20 dep combos                    |
| python-package     | release        | build + publish ag2 and autogen to PyPI                  |

### CI Patterns

- Path filtering via `dorny/paths-filter@v3` (only tests if source changed)
- Concurrency groups with `cancel-in-progress: true`
- Minimal permissions (`permissions: {}`)
- `uv` via `astral-sh/setup-uv@v6` for package management
- Multi-OS: ubuntu, macos, windows
- Docker services in contrib tests: Redis, PostgreSQL (pgvector), MongoDB, Couchbase
- `pytest_sessionfinish` maps exit code 5 (no tests collected) to 0

### PR Gate (pr-checks.yml)

1. pre-commit-check (all hooks except mypy)
2. type-check (mypy on 3 OS)
3. core-test-without-llm (Python 3.11/ubuntu)
4. build-mkdocs (only if docs changed)

## Linting/Formatting

### Ruff (v0.12.12)

| Setting       | Value                                                   |
|---------------|---------------------------------------------------------|
| line-length   | 120                                                     |
| target        | py310                                                   |
| preview       | true                                                    |
| fix           | true                                                    |
| rules         | E, W, C90, N, I, F, ASYNC, C4, Q, SIM, RUF022, UP, D417 |
| ignored       | E501, F403, C901, E402, E721, ASYNC109                  |
| max complexity| 10                                                      |

### mypy (v1.17.1)

| Setting           | Value                              |
|-------------------|------------------------------------|
| python_version    | 3.10                               |
| strict            | true                               |
| plugins           | pydantic.mypy                      |
| follow_imports    | silent                             |
| Coverage          | ~40 specific paths (not whole repo)|

### codespell (v2.4.1)

Spell checker for code and docs. Skips binary/generated files. Large domain-specific ignore list.

## Error Handling Patterns

### Custom Exceptions

Defined in `autogen/exception_utils.py`, all decorated with `@export_module("autogen")`:

| Exception                   | Purpose                        |
|-----------------------------|--------------------------------|
| AgentNameConflictError      | duplicate agent names          |
| NoEligibleSpeakerError      | no speaker in group chat       |
| SenderRequiredError         | missing sender                 |
| InvalidCarryOverTypeError   | wrong carryover format         |
| UndefinedNextAgentError     | next agent not in group        |
| ModelToolNotSupportedError  | model does not support tools   |

### Optional Import Handling

```python
with optional_import_block() as result:
    from PIL.Image import Image
IS_PIL_AVAILABLE = result.is_successful
```

- `require_optional_import(module, reason)` raises descriptive error
- `skip_on_missing_imports(module)` pytest skip decorator
- `ModuleInfo` supports version range checking

### Validation

`ValueError` for invalid arguments. `warnings.warn()` for non-critical issues.

## Convention Patterns

### Agent Definition

Constructor with 18 parameters. Constants as class attributes. Reply registration via `agent.register_reply(trigger, reply_func)` where trigger can be string, agent, class, callable, or list.

### Tool Registration

Three registration methods:

```python
tool.register_for_llm(assistant)
tool.register_for_execution(executor)
tool.register_tool(agent)
```

`@tool(name, description)` decorator converts function to Tool. Dependency injection via ChatContext and Depends parameters (stripped from LLM schema).

### Event Pattern

Events extend `BaseEvent` (Pydantic ABC). `@wrap_event` creates discriminated union wrapper with `type` field. Event naming: `XxxEvent` suffix. 50+ event types across agent, client, and print categories.

### LLM Config Pattern

Multiple construction methods:

```python
LLMConfig(config_list={"model": "gpt-5-nano", "api_type": "openai"})
LLMConfig.from_json(path="OAI_CONFIG_LIST")
llm_config.where(model="gemini-2.5-flash")
```

`Literal[False]` sentinel to disable LLM: `llm_config: LLMConfig | Literal[False]`.

## Pre-commit Hooks

| Hook                         | Purpose                            |
|------------------------------|------------------------------------|
| check-added-large-files      | block large file commits           |
| check-ast                    | validate Python syntax             |
| check-yaml                   | validate YAML files                |
| check-toml                   | validate TOML files                |
| check-json                   | validate JSON files                |
| check-byte-order-marker      | detect BOM                         |
| check-merge-conflict         | detect merge conflict markers      |
| detect-private-key           | prevent committing private keys    |
| trailing-whitespace          | remove trailing whitespace         |
| end-of-file-fixer            | ensure files end with newline      |
| no-commit-to-branch          | prevent direct commits to default  |
| nbstripout                   | strip notebook outputs             |
| build-setup-scripts          | regenerate setup_autogen.py        |
| lint                         | ruff lint + format                 |
| codespell                    | spell checking                     |
| mypy                         | type checking                      |
| check-license-headers        | Apache-2.0 license enforcement     |
| generate-devcontainer-files  | regenerate devcontainer configs    |
