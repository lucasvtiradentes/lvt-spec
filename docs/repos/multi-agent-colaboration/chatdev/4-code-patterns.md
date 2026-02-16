# Code Patterns

## Coding Style and Conventions

Naming:
- snake_case for functions, methods, variables, module names
- PascalCase for classes (GraphExecutor, NodeExecutor, EdgeConditionManager)
- UPPER_SNAKE_CASE for constants (OUTPUT_ROOT, _BUILTINS_LOADED)
- Underscore prefix for private: `_execute_node`, `_outgoing_edges`
- Dunder prefix for name-mangled private: `self.__execution_context`

Imports:
- Standard library first, third-party second, project-internal third (PEP 8 order, not enforced by tooling)
- Relative imports within packages: `from .base import EdgeConditionManager`
- Absolute imports from external packages: `from entity.configs import Node`
- Local/delayed imports to avoid circular dependencies

Type Hints:
- Pervasive but inconsistent. Mixes `Optional[X]` with `X | None`
- Uses `typing` module: Any, Dict, List, Optional, Tuple, Sequence, Union, TypeVar, Generic
- Modern built-in generics also used: `list[str]`, `set[str]`, `dict[str, Any]`

Python Version:
- Requires 3.12+ (strict: `>=3.12,<3.13`)
- Uses modern syntax: `X | None`, `@dataclass(slots=True)`

Docstrings:
- Module-level docstrings on most files (triple-quote, short description)
- Class/method docstrings in Google style (Args:, Returns:, Raises: sections)
- Private helpers often lack docstrings

## Error Handling Patterns

Custom exception hierarchy rooted at `MACException(Exception)`:

```
MACException (base)
  ├── ValidationError
  ├── SecurityError
  ├── ConfigurationError
  ├── WorkflowExecutionError
  ├── WorkflowCancelledError
  ├── ResourceNotFoundError
  ├── ResourceConflictError
  ├── TimeoutError
  └── ExternalServiceError
```

Each carries `error_code`, `message`, `details` dict, and has `to_dict()`/`to_json()` methods.

Separate `ConfigError(ValueError)` in entity layer for parsing errors with a `path` field.

Patterns used:
- Try/except with specific types, re-raise as domain exception with `from exc` chaining
- Guard pattern: `_raise_if_cancelled()` checked before expensive operations
- None-safe defaults: `or {}` / `or []` used heavily
- `isinstance` checks before operating on data

Example:

```python
try:
    raw_data = read_yaml(config_path)
except FileNotFoundError as exc:
    raise DesignError(f"Design file not found: {config_path}") from exc
```

## Testing Approach

No test files exist. No `test_*.py` or `tests/` directory. `pytest` is listed as a dependency but unused.

Validation serves as the primary quality gate:
- `tools/validate_all_yamls.py` recursively validates all YAML files in `yaml_instance/`
- Three layers: schema validation (check_yaml.py), workflow structural validation (check_workflow.py), combined load+validate (check.py)
- CI runs this validation on every PR/push

## CI/CD Setup

Single GitHub Actions workflow: `.github/workflows/validate-yamls.yml`

| Field           | Value                                                                                     |
|-----------------|-------------------------------------------------------------------------------------------|
| Name            | Validate YAML Workflows                                                                   |
| Triggers        | PR (on yaml/workflow/check file changes), push to main, manual                            |
| Runner          | ubuntu-latest                                                                             |
| Python          | 3.12                                                                                      |
| Package Manager | uv (astral-sh/setup-uv@v4) with dependency caching                                        |
| System Deps     | libcairo2-dev, pkg-config (for pycairo)                                                   |
| Build           | hatchling                                                                                 |
| Steps           | checkout -> setup python -> install uv -> install sys deps -> cache -> uv sync -> validate|

No other CI pipelines -- no lint, type check, test, build, or deployment pipeline.

## Code Organization Patterns

| Module           | Responsibility                                           |
|------------------|----------------------------------------------------------|
| check/           | YAML and workflow validation                             |
| entity/          | Configuration data models (configs, enums, messages)     |
| runtime/         | Execution runtime (node executors, edge processors)      |
| workflow/        | Graph orchestration (executor, topology, context)        |
| utils/           | Cross-cutting utilities (logging, registry, exceptions)  |
| schema_registry/ | Schema registration for pluggable types                  |
| server/          | FastAPI server                                           |
| tools/           | CLI maintenance scripts                                  |
| functions/       | Edge condition/processor functions + tool implementations|
| frontend/        | Vue.js frontend                                          |

Key patterns:
1. Registry Pattern          - generic Registry class with lazy loading for all extensible components
2. Strategy Pattern          - execution strategies (DAG, Cycle, MajorityVote)
3. Factory Pattern           - NodeExecutorFactory, MemoryFactory, ThinkingManagerFactory
4. Template Method Pattern   - NodeExecutor ABC, EdgeConditionManager ABC
5. Observer/Hook Pattern     - WorkspaceArtifactHook for file change detection
6. Dataclass-Driven Config   - BaseConfig with FIELD_SPECS, CONSTRAINTS, CHILD_ROUTES
7. Context Pattern           - GraphContext (mutable state) vs GraphConfig (immutable config)

## Configuration Management

Config loading pipeline:

```
Raw YAML ---> resolve ${VAR} ---> validate schema ---> check structure ---> DesignConfig
              (env_loader,         (check_yaml.py)    (check_workflow.py)   (typed dataclass)
               vars_resolver)
```

Variable resolution priority:
1. `vars` block in YAML (highest)
2. System/shell environment variables
3. `.env` file (lowest)

Config hierarchy:

```
DesignConfig
  +-- version
  +-- vars
  +-- GraphDefinition
        +-- nodes: List[Node]
        |     +-- config: variant (AgentConfig, HumanConfig, PythonRunnerConfig, etc.)
        +-- edges: List[EdgeConfig]
        |     +-- condition: EdgeConditionConfig (variant: function, keyword)
        |     +-- process: EdgeProcessorConfig (variant: regex_extract, function)
        |     +-- dynamic: DynamicEdgeConfig
        +-- memory: List[MemoryStoreConfig] (variant: simple, file, blackboard)
```

## Logging and Debugging

Three-layer logging architecture:

| Layer            | File                      | Purpose                                                                                    |
|------------------|---------------------------|--------------------------------------------------------------------------------------------|
| WorkflowLogger   | utils/logger.py           | In-memory execution trace with structured events (NODE_START, MODEL_CALL, TOOL_CALL, etc.) |
| LogManager       | utils/log_manager.py      | Backward-compatible wrapper with domain methods (record_model_call, record_tool_call, etc.)|
| StructuredLogger | utils/structured_logger.py| JSON-per-line file logging with correlation IDs                                            |

Event types: NODE_START, NODE_END, EDGE_PROCESS, MODEL_CALL, TOOL_CALL, THINKING_PROCESS, MEMORY_OPERATION, WORKFLOW_START, WORKFLOW_END

Context managers for timing: `node_timer()`, `model_timer()`, `tool_timer()`, `thinking_timer()`, `memory_timer()`

## YAML Schema Patterns

Variant/polymorphic config dispatched by `type` field:

| Component       | Type Field Values                                                 |
|-----------------|-------------------------------------------------------------------|
| Node config     | agent, human, python, subgraph, passthrough, literal, loop_counter|
| Edge condition  | function, keyword                                                 |
| Edge processor  | regex_extract, function                                           |
| Memory store    | simple, file, blackboard                                          |
| Subgraph source | config (inline), file (external path)                             |
| Tooling         | function, mcp_local, mcp_remote                                   |
| Thinking        | reflection                                                        |
| Provider        | openai, gemini                                                    |

## Linting/Formatting

No Python linting or formatting tools configured. No ruff, black, isort, mypy, pylint, flake8, or pyright settings.

Frontend has ESLint 9 + eslint-plugin-vue.
