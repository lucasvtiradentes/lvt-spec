# AG2 - Usage and Examples

## Getting Started

### Install

```bash
pip install "ag2[openai]"
pip install "ag2[openai,gemini,anthropic]"
pip install "ag2[openai,mcp]"
```

### Configure LLM

```python
from autogen import LLMConfig

llm_config = LLMConfig(
    config_list={"api_type": "openai", "model": "gpt-5-nano", "api_key": os.getenv("OPENAI_API_KEY")}
)

llm_config = LLMConfig.from_json(path="OAI_CONFIG_LIST")
```

OAI_CONFIG_LIST file format:

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

### Quickstart

```python
from autogen import AssistantAgent, UserProxyAgent, LLMConfig

llm_config = LLMConfig.from_json(path="OAI_CONFIG_LIST")

assistant = AssistantAgent("assistant", llm_config=llm_config)
user_proxy = UserProxyAgent("user_proxy", code_execution_config={"work_dir": "coding", "use_docker": False})

user_proxy.run(assistant, message="Summarize the main differences between Python lists and tuples.").process()
```

## Two-Agent Chat

```python
from autogen import ConversableAgent, LLMConfig

coder = ConversableAgent(
    name="coder",
    system_message="You are a Python developer. Write short Python scripts.",
    llm_config=llm_config,
)

reviewer = ConversableAgent(
    name="reviewer",
    system_message="You are a code reviewer. Analyze provided code and suggest improvements.",
    llm_config=llm_config,
)

response = reviewer.run(
    recipient=coder,
    message="Write a Python function that computes Fibonacci numbers.",
    max_turns=10
)
response.process()
```

## Structured Output

```python
from pydantic import BaseModel
from autogen import ConversableAgent, LLMConfig

class LessonPlan(BaseModel):
    title: str
    learning_objectives: list[str]
    script: str

llm_config = LLMConfig(config_list={
    "api_type": "openai",
    "model": "gpt-5-nano",
    "response_format": LessonPlan,
})

agent = ConversableAgent(
    name="lesson_agent",
    system_message="You are a classroom lesson agent.",
    llm_config=llm_config,
)

response = agent.run(message="Let's learn about the solar system!", max_turns=1)
response.process()
```

## Group Chat

### Auto Speaker Selection

```python
from autogen import ConversableAgent, GroupChat, GroupChatManager, LLMConfig

planner = ConversableAgent(name="planner", system_message="...", llm_config=llm_config)
reviewer = ConversableAgent(name="reviewer", system_message="...", llm_config=llm_config)
teacher = ConversableAgent(
    name="teacher",
    system_message="...",
    is_termination_msg=lambda x: "DONE!" in (x.get("content", "") or "").upper(),
    llm_config=llm_config,
)

groupchat = GroupChat(
    agents=[teacher, planner, reviewer],
    speaker_selection_method="auto",
    messages=[],
)

manager = GroupChatManager(name="manager", groupchat=groupchat, llm_config=llm_config)
teacher.initiate_chat(recipient=manager, message="Introduce the solar system.")
```

### AutoPattern (new API)

```python
from autogen.agentchat import run_group_chat
from autogen.agentchat.group.patterns import AutoPattern

pattern = AutoPattern(
    agents=[teacher, planner, reviewer],
    initial_agent=planner,
    group_manager_args={"name": "manager", "llm_config": llm_config},
)

response = run_group_chat(pattern=pattern, messages="Introduce the solar system.", max_rounds=20)
response.process()
```

### Custom Speaker Selection Function

```python
def custom_speaker(last_speaker, groupchat):
    messages = groupchat.messages
    if last_speaker is planner:
        return reviewer
    elif last_speaker is reviewer:
        if "approve" in messages[-1]["content"].lower():
            return executor
        return planner
    return "random"

groupchat = GroupChat(
    agents=[planner, reviewer, executor],
    messages=[],
    max_round=20,
    speaker_selection_method=custom_speaker,
)
```

### FSM Transitions

```python
speaker_transitions = {
    agent_a: [agent_b, agent_c],
    agent_b: [agent_a],
    agent_c: [agent_a, agent_b],
}

groupchat = GroupChat(
    agents=[agent_a, agent_b, agent_c],
    messages=[],
    max_round=20,
    allowed_or_disallowed_speaker_transitions=speaker_transitions,
    speaker_transitions_type="allowed",
)
```

## Sequential Chats

```python
chat_results = teacher.initiate_chats([
    {
        "recipient": curriculum_agent,
        "message": "What's a good science topic?",
        "max_turns": 1,
        "summary_method": "last_msg",
    },
    {
        "recipient": planner,
        "message": "Create a lesson plan.",
        "max_turns": 2,
        "summary_method": "last_msg",
    },
    {
        "recipient": formatter,
        "message": "Format the lesson plan.",
        "max_turns": 1,
        "summary_method": "last_msg",
    },
])

print("Summary:", chat_results[0].summary)
```

## Nested Chats

```python
nested_chats = [
    {
        "recipient": curriculum_agent,
        "message": lambda r, m, s, c: f"Provide standards for: {m[-1]['content']}",
        "max_turns": 2,
        "summary_method": "last_msg",
    },
    {
        "recipient": planner,
        "message": "Based on these standards, create a lesson plan.",
        "max_turns": 1,
        "summary_method": "last_msg",
    },
]

lead_teacher.register_nested_chats(
    chat_queue=nested_chats,
    trigger=lambda sender: sender not in [curriculum_agent, planner],
)
```

## Swarm (Hand-offs + Context Variables)

```python
from autogen import (
    AfterWork, OnCondition, AfterWorkOption,
    ConversableAgent, SwarmResult,
    initiate_swarm_chat, register_hand_off, LLMConfig,
)

shared_context = {"lesson_plans": [], "reviews_left": 2}

def record_plan(plan: str, context_variables: dict) -> SwarmResult:
    context_variables["lesson_plans"].append(plan)
    return SwarmResult(context_variables=context_variables)

planner = ConversableAgent(
    name="planner",
    system_message="...",
    functions=[record_plan],
    llm_config=llm_config,
)

register_hand_off(planner, [
    OnCondition(target=reviewer, condition="Plan must be reviewed.", available="reviews_left"),
    AfterWork(agent=teacher),
])

result, ctx, last = initiate_swarm_chat(
    initial_agent=teacher,
    agents=[planner, reviewer, teacher],
    messages="Introduce the solar system.",
    context_variables=shared_context,
)
```

## Tool Use

### register_function

```python
from typing import Annotated
from autogen import ConversableAgent, register_function, LLMConfig

def get_weekday(date_string: Annotated[str, "Format: YYYY-MM-DD"]) -> str:
    from datetime import datetime
    return datetime.strptime(date_string, "%Y-%m-%d").strftime("%A")

caller = ConversableAgent(name="caller", system_message="...", llm_config=llm_config)
executor = ConversableAgent(name="executor", human_input_mode="NEVER")

register_function(
    get_weekday,
    caller=caller,
    executor=executor,
    description="Get the day of the week for a given date",
)

result = executor.initiate_chat(recipient=caller, message="What day was March 25, 1995?", max_turns=2)
```

### Decorator Style

```python
@executor.register_for_execution()
@caller.register_for_llm(description="Run Python code.")
def exec_python(cell: Annotated[str, "Valid Python code"]) -> str:
    ...
```

### Tool Class

```python
from autogen.tools import Tool

tool = Tool(name="calculator", description="Does math", func_or_tool=calc_func)
tool.register_for_llm(assistant)
tool.register_for_execution(executor)
```

## MCP Integration

```bash
pip install "ag2[openai,mcp]"
```

```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from autogen.mcp import create_toolkit

async def run_with_mcp(session: ClientSession):
    toolkit = await create_toolkit(session=session)
    agent = AssistantAgent(name="assistant", llm_config=llm_config)
    toolkit.register_for_llm(agent)

    result = await agent.a_run(
        message="Add 123 and 456",
        tools=toolkit.tools,
        max_turns=2,
        user_input=False,
    )
    await result.process()

server_params = StdioServerParameters(command="python", args=["mcp_server.py", "stdio"])

async with stdio_client(server_params) as (read, write), ClientSession(read, write) as session:
    await session.initialize()
    await run_with_mcp(session)
```

Supports three transports: stdio, SSE, streamable-http.

## Human in the Loop

```python
human = ConversableAgent(name="human", human_input_mode="ALWAYS")
agent = ConversableAgent(name="agent", system_message="...", llm_config=llm_config)

human.initiate_chat(recipient=agent, message="Let's plan a lesson.")
```

Three modes:
- `"ALWAYS"`    - agent always prompts human
- `"TERMINATE"` - prompts only on termination
- `"NEVER"`     - fully autonomous

## Code Execution

### Local

```python
from autogen.coding import LocalCommandLineCodeExecutor

executor = LocalCommandLineCodeExecutor(timeout=10, work_dir="/tmp/coding")

agent = ConversableAgent(
    "executor",
    llm_config=False,
    code_execution_config={"executor": executor},
    human_input_mode="ALWAYS",
)
```

### Docker

```python
from autogen.coding import DockerCommandLineCodeExecutor

executor = DockerCommandLineCodeExecutor(
    image="python:3.12-slim",
    timeout=10,
    work_dir="/tmp/coding",
)
```

### PythonCodeExecutionTool with Docker Environment

```python
from autogen.environments import DockerPythonEnvironment, WorkingDirectory
from autogen.tools.experimental import PythonCodeExecutionTool

with DockerPythonEnvironment(image="python:3.11-slim", pip_packages=["numpy", "pandas"]) as env:
    with WorkingDirectory(path="/tmp/work") as wd:
        python_executor = PythonCodeExecutionTool(timeout=60)
```

## LLM Provider Examples

### OpenAI

```python
LLMConfig(config_list={"api_type": "openai", "model": "gpt-5-nano", "api_key": os.environ["OPENAI_API_KEY"]})
```

### Azure OpenAI

```python
LLMConfig(config_list={
    "model": "my-deployment",
    "api_type": "azure",
    "api_key": "<key>",
    "base_url": "https://endpoint.openai.azure.com/",
    "api_version": "2025-01-01",
})
```

### Ollama (local)

```python
LLMConfig({
    "model": "llama3.1:8b",
    "api_type": "ollama",
    "stream": False,
    "client_host": "http://localhost:11434",
})
```

### Gemini

```python
LLMConfig(config_list={"api_type": "google", "model": "gemini-2.5-flash", "api_key": os.environ["GEMINI_API_KEY"]})
```

### Anthropic

```python
LLMConfig(config_list={"api_type": "anthropic", "model": "claude-sonnet-4-5-20250929", "api_key": os.environ["ANTHROPIC_API_KEY"]})
```

## Interoperability

### LangChain Tools

```python
from langchain_community.tools import WikipediaQueryRun
from autogen.interop import Interoperability

ag2_tool = Interoperability().convert_tool(tool=langchain_tool, type="langchain")
ag2_tool.register_for_execution(user_proxy)
ag2_tool.register_for_llm(chatbot)
```

### CrewAI Tools

```python
from crewai_tools import ScrapeWebsiteTool
from autogen.interop import Interoperability

ag2_tool = Interoperability().convert_tool(tool=ScrapeWebsiteTool(), type="crewai")
```

### PydanticAI Tools

```python
from pydantic_ai.tools import Tool as PydanticAITool
from autogen.interop import Interoperability

ag2_tool = Interoperability().convert_tool(tool=pydantic_ai_tool, type="pydanticai", deps=my_deps)
```

## Common Workflows

1. Two-Agent Chat       - simplest, one agent talks to another
2. Sequential Chats     - chain of two-agent conversations with carryover
3. Group Chat           - multiple agents with speaker selection
4. Nested Chats         - sub-conversations packaged as single agent
5. Swarm                - dynamic hand-offs with shared context

### Pattern Cookbook (9 patterns)

| Pattern              | Description                                   |
|----------------------|-----------------------------------------------|
| Context-Aware        | route to specialized agents based on context  |
| Escalation           | tiered support with human handoff             |
| Feedback Loop        | iterative refinement between agents           |
| Organic              | agents organically choose next speaker        |
| Hierarchical         | tree structure with delegation                |
| Pipeline             | sequential processing stages                  |
| Redundant            | multiple agents verify each other             |
| Star                 | hub-and-spoke coordination                    |
| Triage with Tasks    | categorize then assign to specialists         |

## Notable Notebooks

| Notebook                                       | Topic                              |
|------------------------------------------------|------------------------------------|
| agentchat_auto_feedback_from_code_execution    | stock analysis with code execution |
| agentchat_groupchat                            | group chat research                |
| agentchat_RetrieveChat                         | RAG retrieval augmented generation |
| agentchat_nested_chats_chess                   | chess via nested chats             |
| agentchat_dalle_and_gpt4v                      | image generation                   |
| agentchat_mcp_filesystem                       | MCP filesystem tools               |
| agentchat_agents_deep_researcher               | deep research agent                |
| agentchat_captainagent                         | auto-builds agent teams            |
| agentchat_reasoning_agent                      | reasoning patterns                 |
| agentchat_graph_rag_neo4j                      | graph RAG with Neo4j               |
| agentchat_agents_websurfer                     | web browsing agent                 |
