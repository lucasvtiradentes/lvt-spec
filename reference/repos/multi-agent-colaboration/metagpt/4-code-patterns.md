# MetaGPT - Code Patterns

## Coding Style

### Naming Conventions

| Element   | Convention                | Examples                                           |
|-----------|---------------------------|----------------------------------------------------|
| Classes   | PascalCase                | BaseLLM, OpenAILLM, ActionNode, WritePRD           |
| Functions | snake_case                | _achat_completion, publish_message, get_choice_text|
| Constants | UPPER_SNAKE_CASE          | MESSAGE_ROUTE_TO_ALL, LLM_API_TIMEOUT              |
| Variables | snake_case                | rsp_cache, task_map, collected_messages            |
| Enums     | PascalCase + UPPER members| LLMType.OPENAI, RoleReactMode.REACT                |
| Private   | underscore prefix         | _think, _act, _observe                             |

### File Organization

Every module follows this order:

1. Shebang + encoding declaration
2. Module docstring with @Time, @Author, @File, @Modified By
3. `from __future__ import annotations` (when needed)
4. Standard library imports
5. Third-party imports
6. Internal imports
7. Module-level constants/templates
8. Class definitions
9. Module-level instances/singletons

Example header:

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@Time    : 2023/5/11 14:42
@Author  : alexanderwu
@File    : role.py
@Modified By: mashenquan, 2023/8/22. ...
"""
```

### Import Patterns

- isort with Black profile enforces import order
- `from __future__ import annotations` for forward references
- `typing.TYPE_CHECKING` guard to avoid circular imports
- Late imports inside methods for circular dependency resolution
- `__init__.py` files re-export key classes with `__all__`
- `noqa: F401` for side-effect-only imports

### Line Length

120 characters, enforced by Black and Ruff.

## Type Hints Usage

Type hints are used extensively but not universally:

- All Pydantic model fields are typed
- Function signatures generally carry type hints for params and returns
- Modern Python 3.9+ syntax in many places: `list[str]`, `dict[str, Task]`, `set[str]`
- Some older areas still use `from typing import List, Dict, Optional, Union`
- `TypeVar` for generics: `T = TypeVar("T", bound="BaseModel")`
- `SerializeAsAny` from Pydantic for polymorphic serialization

Example:

```python
async def aask(
    self,
    msg: Union[str, list[dict[str, str]]],
    system_msgs: Optional[list[str]] = None,
    timeout=USE_CONFIG_TIMEOUT,
) -> str:
```

## Error Handling Patterns

### Custom Exceptions

Defined sparingly, placed close to usage:

| Exception          | Location                | Purpose                            |
|--------------------|-------------------------|------------------------------------|
| NoMoneyException   | utils/common.py         | raised when budget exceeded        |
| RateLimitError     | utils/git_repository.py | API rate limit hit                 |
| LineNumberError    | tools/libs/editor.py    | invalid line number in editor      |
| EnvKeyNotFoundError| tools/libs/env.py       | missing environment key            |
| TimeoutException   | ext/sela/experimenter.py| operation timeout                  |

### handle_exception Decorator

Central decorator in `utils/exceptions.py` that wraps sync/async functions, catches specified exception types, logs full stack traces via loguru, returns a configurable default:

```python
@handle_exception
def serialize(self, file_path: str = None) -> str: ...

@handle_exception(exception_type=JSONDecodeError, default_return=None)
def load(val): ...
```

### Retry Pattern (tenacity)

Used heavily for LLM API calls:

```python
@retry(
    stop=stop_after_attempt(3),
    wait=wait_random_exponential(min=1, max=60),
    after=after_log(logger, logger.level("WARNING").name),
    retry=retry_if_exception_type(ConnectionError),
    retry_error_callback=log_and_reraise,
)
async def acompletion_text(self, messages, stream=False, timeout=USE_CONFIG_TIMEOUT) -> str:
```

Typical configs: 2-6 retry attempts, random exponential backoff (1-60s), retrying on specific exceptions.

### General Patterns

- Bare `except Exception` with logger.error in non-critical paths
- `contextlib.suppress(Exception)` for silently ignoring benign failures
- `assert` statements for preconditions (e.g., `assert react_mode in RoleReactMode.values()`)
- `raise NotImplementedError` in abstract/template methods

## Testing Approach

### Framework

pytest as test runner with plugins: pytest-asyncio, pytest-cov, pytest-mock, pytest-html, pytest-xdist, pytest-timeout.

### Test Organization

```
tests/
├── conftest.py       - global fixtures (llm_mock, context, rsp_cache, proxy)
├── data/             - test data, response caches (rsp_cache.json)
├── mock/             - mock classes (MockLLM, MockAioResponse)
└── metagpt/          - mirrors source structure
    ├── actions/
    ├── configs/
    ├── environment/
    ├── memory/
    ├── provider/
    ├── rag/
    ├── roles/
    ├── tools/
    └── utils/
```

### LLM Mocking Strategy

Sophisticated response-cache-based system (in conftest.py):

1. MockLLM extends real LLM but intercepts aask, aask_batch, aask_code
2. Looks up messages in rsp_cache.json; if found, returns cached response
3. If not found and ALLOW_OPENAI_API_CALL=0, raises ValueError
4. After tests pass, new API responses are appended to cache
5. Global llm_mock fixture (function-scoped, autouse) patches BaseLLM.aask and BaseLLM.aask_batch

### Test Style

- `@pytest.mark.asyncio` for async tests
- `unittest.mock.MagicMock` for mocking LLM behavior
- `test_<functionality>` naming convention
- Assertions on return types, message routing, behavioral correctness

### Coverage

- pytest-cov with `--cov=./metagpt/` outputting XML and HTML
- Massive ignore list in pytest.ini (~130 files) excluding tests needing real API keys
- norecursedirs excludes ext/ and environment tests

## CI/CD Pipeline

### Workflows (in .github/workflows/)

| Workflow           | Trigger                                    | Purpose                                    |
|--------------------|--------------------------------------------|--------------------------------------------|
| unittest.yaml      | push to main/dev/*-release, PR target      | unit tests with mocked LLM (no API calls)  |
| fulltest.yaml      | same + workflow_dispatch + *-debugger      | full tests with real API keys from secrets |
| pre-commit.yaml    | all branches (push + PR)                   | runs isort, ruff, black via pre-commit     |
| build-package.yaml | release create/publish, workflow_dispatch  | builds wheel+sdist, uploads to PyPI        |
| stale.yaml         | daily cron                                 | stales issues after 30 days, closes at 44  |

### Unit Test Pipeline Details

- Python 3.9, ubuntu-22.04
- `pip install -e .[test]`, mermaid-cli, playwright
- ALLOW_OPENAI_API_CALL=0
- Coverage report + failed test analysis
- Artifacts: unittest.txt, htmlcov, rsp_cache_new.json

### Pre-commit Hooks

Order: isort (5.11.5) ---> ruff (v0.0.284, with --fix) ---> black (23.3.0)

## Logging

### Library

loguru (0.6.0) wrapped in metagpt/logs.py.

### Configuration

`define_log_level()` configures:
- stderr output at INFO level
- file output at DEBUG level to `logs/<date>.txt`

### Usage Levels

| Level   | Usage                                                    |
|---------|----------------------------------------------------------|
| info    | cost updates, investment amounts, configuration state    |
| debug   | message routing, role state transitions, LLM messages    |
| warning | missing token costs, invalid state, fallback behavior    |
| error   | parse failures, API errors, schema mismatches            |

### Specialized Logging

- `log_llm_stream()` writes streaming LLM tokens to asyncio.Queue via ContextVar for UI consumption
- `log_tool_output()` pluggable via `set_tool_output_logfunc()` for routing tool outputs

## Configuration Management

### Structure

YAML-based, modeled with Pydantic. Individual config models in `metagpt/configs/` per feature. Main `Config` class in `config2.py` aggregates all sub-configs.

### Loading Priority

```
env vars < METAGPT_ROOT/config/config2.yaml < ~/.metagpt/config2.yaml < kwargs
```

### YamlModel Base

`utils/yaml_model.py` provides `YamlModel(BaseModel)` with read_yaml(), from_yaml_file(), to_yaml_file().

### Validation

- `LLMConfig.check_llm_key` raises ValueError if API key is empty/placeholder
- `CLIParams.check_project_path` auto-sets `inc=True` if project_path provided

## Async Patterns

The codebase is heavily async, built around asyncio:

### Core Async Flow

```
Team.run()
  --> Environment.run()
    --> asyncio.gather(*[role.run() for active roles])
      --> Role.run()
        --> Role._observe() --> Role.react()
          --> Role._think() --> Role._act()
            --> Action.run() --> BaseLLM.aask()
              --> provider._achat_completion()
```

### Key Patterns

- AsyncOpenAI client for all OpenAI-compatible APIs
- asyncio.Queue for message buffering (MessageQueue) and LLM stream buffering
- asyncio.gather() for concurrent role execution
- asyncio.wait_for() with timeouts for queue operations
- aiofiles for async file I/O
- aiohttp for async HTTP requests
- ContextVar for thread-safe LLM stream queues

## Design Patterns in Code

| Pattern         | Implementation                                                          |
|-----------------|-------------------------------------------------------------------------|
| Registry        | LLMProviderRegistry + @register_provider, ToolRegistry + @register_tool |
| Singleton       | Singleton metaclass in utils/singleton.py                               |
| Mixin           | ContextMixin provides context/config/llm to Role and Action             |
| Template Method | Role: run() -> _observe() -> react() -> _think() -> _act()              |
| Strategy        | RoleReactMode: REACT, BY_ORDER, PLAN_AND_ACT                            |
| Observer        | Roles _watch action types, Environment routes via pub/sub               |
| Factory         | create_llm_instance(), Config.default(), RAG factories                  |
| Decorator       | @handle_exception, @retry, @register_tool, @serialize_decorator         |
| Serialization   | SerializationMixin for JSON persistence of Pydantic models              |
| Command         | RoleZero dispatches structured commands to tool_execution_map           |

## Code Conventions

### Docstring Styles (Mixed)

Google-style (newer code):

```python
def update_cost(self, prompt_tokens, completion_tokens, model):
    """
    Update the total cost, prompt tokens, and completion tokens.

    Args:
        prompt_tokens (int): The number of tokens used in the prompt.
    """
```

Sphinx-style (older code):

```python
def get_meta(self) -> Document:
    """Get metadata of the document.

    :return: A new Document instance.
    """
```

### Chinese Comments

Many inline comments are in Chinese (original dev team language), sometimes with English translations.

### Pydantic Usage

- All data models inherit from pydantic.BaseModel
- ConfigDict(arbitrary_types_allowed=True) for non-serializable types
- Field(default_factory=...), Field(exclude=True), PrivateAttr
- @model_validator(mode="before"/"after") for complex init
- @field_validator, @field_serializer for field-level logic
- SerializeAsAny for polymorphic serialization

### Linting/Formatting Config

| Tool   | Config                                                         |
|--------|----------------------------------------------------------------|
| Ruff   | selects E + F, ignores E501/E712/E722/F821/E731, target py39   |
| Black  | line-length 120                                                |
| isort  | profile "black", excludes __init__.py                          |

### Internal RFCs Referenced

| RFC | Topic                                            |
|-----|--------------------------------------------------|
| 113 | routing and transport framework                  |
| 116 | message distribution and type indexing           |
| 135 | document storage, message structure, archiving   |
| 236 | requirement analysis                             |
