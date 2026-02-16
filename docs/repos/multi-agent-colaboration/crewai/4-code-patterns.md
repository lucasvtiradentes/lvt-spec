# CrewAI - Code Patterns

## Coding Style

Indentation: 2-space for all Python files (from .editorconfig). Most Python projects use 4 but crewAI uses 2.

Type hints: mandatory, enforced by mypy strict mode with Pydantic plugin. Modern syntax used:
- `str | None` instead of `Optional[str]`
- `dict[str, Any]` instead of `Dict[str, Any]`
- `from __future__ import annotations` in 120+ source files

Naming:
- Classes:           PascalCase (`CrewAIEventsBus`, `BaseAgent`, `TaskOutput`)
- Functions/methods: snake_case (`execute_task`, `kickoff_for_each`)
- Private:           single underscore prefix (`_execute_tasks`, `_cache_handler`)
- Constants:         UPPER_SNAKE_CASE (`MCP_CONNECTION_TIMEOUT`, `FINAL_ANSWER_ACTION`)
- Enum members:      lowercase (`Process.sequential`, `Process.hierarchical`)

Imports: absolute only (relative imports banned), sorted by ruff isort with 2 blank lines after imports.

Line length: no maximum (E501 ignored).

## Data Modeling

Pydantic BaseModel is the foundation for all core domain objects:

```python
class Crew(FlowTrackable, BaseModel):
  name: str | None = Field(default="crew")
  cache: bool = Field(default=True)
  tasks: list[Task] = Field(default_factory=list)

  _rpm_controller: RPMController = PrivateAttr()
  _cache_handler: InstanceOf[CacheHandler] = PrivateAttr(default_factory=CacheHandler)

  @field_validator("id", mode="before")
  @classmethod
  def _deny_user_set_id(cls, v: UUID4 | None) -> None:
    if v:
      raise PydanticCustomError("may_not_set_field", "Cannot set 'id'.", {})

  @model_validator(mode="after")
  def set_private_attrs(self) -> Crew:
    self._cache_handler = CacheHandler()
    return self
```

Custom Pydantic error codes used throughout: `"may_not_set_field"`, `"missing_manager_llm_or_manager_agent"`, `"output_type"`, `"async_task_count"`.

## Error Handling

Event-driven pattern (most common):
```python
try:
  result = self._run_sequential_process()
  return result
except Exception as e:
  crewai_event_bus.emit(self, CrewKickoffFailedEvent(error=str(e)))
  raise
finally:
  clear_files(self.id)
```

Event pairs: every Started event has Completed and Failed counterparts (40+ pairs).

Graceful degradation for optional imports:
```python
try:
  from crewai_files import get_supported_content_types
  HAS_CREWAI_FILES = True
except ImportError:
  HAS_CREWAI_FILES = False
  def get_supported_content_types(provider, api=None):
    return []
```

Guardrail retry pattern:
```python
for attempt in range(max_attempts):
  guardrail_result = process_guardrail(output=task_output, guardrail=guardrail)
  if guardrail_result.success:
    return task_output
  if attempt >= self.guardrail_max_retries:
    raise Exception(f"Validation failed after {self.guardrail_max_retries} retries")
  result = agent.execute_task(task=self, context=context, tools=tools)
```

Context length exceeded detection via pattern matching against known error strings:
```python
CONTEXT_LIMIT_ERRORS = [
  "maximum context length", "context_length_exceeded",
  "too many tokens", "input is too long", "exceeds token limit",
]
```

Security validation on output file paths:
```python
if ".." in value:
  raise ValueError("Path traversal attempts are not allowed")
if value.startswith(("~", "$")):
  raise ValueError("Shell expansion characters are not allowed")
if any(char in value for char in ["|", ">", "<", "&", ";"]):
  raise ValueError("Shell special characters are not allowed")
```

## Testing

Framework: pytest 8.4.2 with parallel execution (xdist), 60s timeout, network blocked by default.

Configuration:
```toml
[tool.pytest.ini_options]
testpaths = ["lib/crewai/tests", "lib/crewai-tools/tests", "lib/crewai-files/tests"]
asyncio_mode = "strict"
addopts = "--tb=short -n auto --timeout=60 --dist=loadfile --block-network"
```

Key plugins:
- pytest-xdist (parallel, `-n auto`)
- pytest-asyncio (strict async mode)
- pytest-recording + vcrpy (HTTP cassette recording/replay)
- pytest-randomly (randomized test order)
- pytest-timeout (60s per test)
- pytest-split (CI test splitting)

VCR cassettes: organized by module path, 40+ sensitive headers filtered, gzip decompressed. Record mode "none" in GitHub Actions.

Root conftest fixtures (all autouse, function-scoped):
1. Event cleanup - clears all sync/async handlers after each test
2. Event state reset - resets emission counter and context stack
3. Test environment - creates temp CREWAI_STORAGE_DIR, sets CREWAI_TESTING=true

Test patterns:

Standalone function tests (most common):
```python
def test_task_tool_reflect_agent_tools():
  researcher = Agent(role="Researcher", goal="...", backstory="...")
  task = Task(description="...", expected_output="...", agent=researcher)
  assert task.tools == [fake_tool]
```

Mocking LLM calls:
```python
with patch.object(Agent, "execute_task") as execute:
  execute.return_value = "ok"
  task.execute_sync(agent=researcher)
  execute.assert_called_once_with(task=task, context=None, tools=[])
```

Exception testing:
```python
with pytest.raises(pydantic_core._pydantic_core.ValidationError, match="at least one non-conditional"):
  Crew(agents=[researcher], tasks=[conditional1, conditional2])
```

Test ruff exceptions: assert (S101), hardcoded passwords (S105/S106), unnecessary return vars (RET504).

## CI/CD Pipeline

GitHub Actions workflows:

| Workflow                    | Trigger          | Purpose                              |
|-----------------------------|------------------|--------------------------------------|
| tests.yml                   | pull_request     | Python 3.10-3.13 x 8 groups (32 jobs)|
| linter.yml                  | pull_request     | Ruff on changed files only           |
| type-checker.yml            | pull_request     | mypy on changed src/ files           |
| codeql.yml                  | push/PR to main  | Security analysis (Python + Actions) |
| publish.yml                 | dispatch/manual  | PyPI publishing (trusted publishing) |
| stale.yml                   | daily cron       | Issue/PR staleness management        |
| build-uv-cache.yml          | -                | Pre-build dependency cache           |
| docs-broken-links.yml       | -                | Documentation link validation        |
| update-test-durations.yml   | -                | pytest-split duration data           |

Test pipeline details:
- Full history checkout (fetch-depth: 0)
- uv cache restored by Python version + lockfile hash
- Tests split into 8 groups via pytest-split
- Max 3 failures before stopping (--maxfail=3)
- uv 0.8.4 in CI

Publishing:
- Builds all packages with `uv build --all-packages`
- Skips crewai_devtools (private)
- Uses PyPI trusted publishing (OIDC, id-token: write)

## Code Quality Tools

Ruff (0.14.7):
```
Rules: E, F, B, S, RUF, N, W, I, T, PERF, PIE, TID, ASYNC, RET, UP*
Ignored: E501 (no line length limit)
Target: py310
Ban relative imports: all
Auto-fix: enabled
```

mypy (1.19.0):
```
strict = true
disallow_untyped_defs = true
disallow_any_unimported = true
python_version = "3.12"
plugins = ["pydantic.mypy"]
Excludes: templates, tests
```

Bandit: via ruff S rules, excludes CLI templates.

Pre-commit hooks:
1. ruff check
2. ruff format
3. mypy (excludes templates/tests)
4. uv-lock consistency
5. commitizen (commit message format)
6. commitizen-branch (branch naming, pre-push)

## Key Conventions

Sentinel pattern:
```python
class _NotSpecified:
  pass
NOT_SPECIFIED = _NotSpecified()
context: list[Task] | None | _NotSpecified = Field(default=NOT_SPECIFIED)
```

ContextVar pattern (thread-local state):
```python
_current_call_id: contextvars.ContextVar[str | None] = contextvars.ContextVar("_current_call_id", default=None)

@contextmanager
def llm_call_context():
  call_id = str(uuid.uuid4())
  token = _current_call_id.set(call_id)
  try:
    yield call_id
  finally:
    _current_call_id.reset(token)
```

ID protection (all core objects prevent user-set IDs):
```python
@field_validator("id", mode="before")
@classmethod
def _deny_user_set_id(cls, v):
  if v:
    raise PydanticCustomError("may_not_set_field", "Cannot set 'id'.", {})
```

Fingerprint/key pattern (deterministic identity via MD5):
```python
@property
def key(self):
  source = [agent.key for agent in self.agents] + [task.key for task in self.tasks]
  return md5("|".join(source).encode(), usedforsecurity=False).hexdigest()
```

Async duality - three levels:
- `kickoff()`       - synchronous
- `kickoff_async()` - thread-wrapped (`asyncio.to_thread`)
- `akickoff()`      - native async

Deep copy with remapping:
```python
def copy(self):
  cloned_agents = [agent.copy() for agent in self.agents]
  task_mapping = {}
  for task in self.tasks:
    cloned_task = task.copy(cloned_agents, task_mapping)
    task_mapping[task.key] = cloned_task
  # Remap context references
  for cloned, original in zip(cloned_tasks, self.tasks):
    if isinstance(original.context, list):
      cloned.context = [task_mapping[ct.key] for ct in original.context]
```

Deprecation pattern:
```python
max_retries: int | None = Field(default=None, description="[DEPRECATED] Use guardrail_max_retries")

@model_validator(mode="after")
def handle_max_retries_deprecation(self):
  if self.max_retries is not None:
    warnings.warn("'max_retries' is deprecated, use 'guardrail_max_retries'", DeprecationWarning)
    self.guardrail_max_retries = self.max_retries
  return self
```

Feature detection via hasattr/getattr:
```python
if hasattr(agent, "allow_delegation") and getattr(agent, "allow_delegation", False):
  # add delegation tools
```

## Logging

Custom Logger class gated by `verbose` flag:
```python
class Logger(BaseModel):
  verbose: bool = Field(default=False)
  def log(self, level, message, color=None):
    if self.verbose:
      timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
      self._printer.print([
        ColoredText(f"[{timestamp}]", "cyan"),
        ColoredText(f"[{level.upper()}]: ", "yellow"),
        ColoredText(message, color or self.default_color),
      ])
```

Standard library `logging` used in infrastructure-level code (LLM providers, MCP, flow engine). Event system serves as the primary observability mechanism with 40+ event types.

## Documentation Style

Module docstrings: present on key modules (Google style).
Class docstrings: Google style with `Attributes:` sections.
Method docstrings: Google style with `Args:`, `Returns:`, `Raises:`.
Inline comments: explain non-obvious logic, not restating code.
Type suppression: always specific codes (`# type: ignore[assignment]`, `# noqa: S110`).
