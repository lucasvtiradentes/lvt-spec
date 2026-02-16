# MetaGPT - Usage and Examples

## Quick Start

### Install

```bash
pip install --upgrade metagpt
npm install -g @mermaid-js/mermaid-cli  # optional, for diagrams
```

### Configure

```bash
metagpt --init-config
```

Edit `~/.metagpt/config2.yaml`:

```yaml
llm:
  api_type: "openai"
  model: "gpt-4-turbo"
  base_url: "https://api.openai.com/v1"
  api_key: "YOUR_API_KEY"
```

### Run

```bash
metagpt "Create a 2048 game"
```

Output lands in `./workspace/`.

## CLI Commands and Options

Entry point: `metagpt=metagpt.software_company:app` (Typer CLI).

```
metagpt [OPTIONS] [IDEA]
```

| Option                             | Type    | Default | Description                                   |
|------------------------------------|---------|---------|-----------------------------------------------|
| IDEA (argument)                    | TEXT    | -       | your requirement, e.g. "Create a 2048 game"   |
| --investment                       | FLOAT   | 3.0     | dollar budget for API calls                   |
| --n-round                          | INTEGER | 5       | number of simulation rounds                   |
| --code-review / --no-code-review   | BOOL    | True    | enable code review                            |
| --run-tests / --no-run-tests       | BOOL    | False   | enable QA test running                        |
| --implement / --no-implement       | BOOL    | True    | enable code implementation                    |
| --project-name                     | TEXT    | ""      | unique project name                           |
| --inc / --no-inc                   | BOOL    | False   | incremental mode (existing repo)              |
| --project-path                     | TEXT    | ""      | path to existing project for incremental dev  |
| --reqa-file                        | TEXT    | ""      | source file for rewriting QA code             |
| --max-auto-summarize-code          | INTEGER | 0       | max SummarizeCode invocations (-1=unlimited)  |
| --recover-path                     | TEXT    | None    | recover from serialized storage               |
| --init-config / --no-init-config   | BOOL    | False   | initialize config file                        |

### CLI Examples

```bash
metagpt "Write a cli snake game"
metagpt "Write a cli snake game" --no-implement
metagpt "Write a cli snake game" --code_review
metagpt "Write a cli snake game based on pygame"
metagpt "Add leaderboard" --inc --project-path ./workspace/game_2048
```

## Python API

### generate_repo - Simplest API

```python
from metagpt.software_company import generate_repo

repo = generate_repo("Create a 2048 game")
print(repo)
```

Parameters: idea, investment (3.0), n_round (5), code_review (True), run_tests (False), implement (True), project_name, inc, project_path, reqa_file, max_auto_summarize_code, recover_path.

### Team API - Core Orchestration

```python
import asyncio
from metagpt.team import Team
from metagpt.roles import ProductManager, Architect, Engineer2

team = Team()
team.hire([ProductManager(), Architect(), Engineer2()])
team.invest(10.0)
team.run_project("Create a snake game")
await team.run(n_round=5)
```

Key methods:

| Method                        | Description                                |
|-------------------------------|--------------------------------------------|
| hire(roles: list[Role])       | add roles to the team                      |
| invest(investment: float)     | set budget                                 |
| run_project(idea, send_to="") | publish user requirement as Message        |
| run(n_round, idea, send_to)   | async, run until done or no money          |
| serialize(stg_path)           | save state to disk                         |
| deserialize(stg_path, ctx)    | restore state from disk                    |

### LLM Direct Access

```python
from metagpt.llm import LLM

llm = LLM()
response = await llm.aask("What is 2+2?", system_msgs=["You are helpful."])
responses = await llm.aask_batch(["hi", "write hello world"])
text = await llm.acompletion_text(messages, stream=True)
```

Vision support:

```python
from metagpt.utils.common import encode_image
img_b64 = encode_image("path/to/image.png")
response = await llm.aask(msg="Describe this image", images=[img_b64])
```

## Common Workflows

### 1. Software Development (Default)

```bash
metagpt "Create a 2048 game"
```

Hires TeamLeader, ProductManager, Architect, Engineer2, DataAnalyst. Produces PRD, system design, code.

### 2. Data Analysis / Machine Learning

```python
from metagpt.roles.di.data_interpreter import DataInterpreter

di = DataInterpreter()
await di.run("Run data analysis on sklearn Iris dataset, include a plot")
```

### 3. Research

```python
from metagpt.roles.researcher import Researcher

researcher = Researcher(language="en-us")
await researcher.run("dataiku vs. datarobot")
```

### 4. Web Scraping

```python
from metagpt.roles.di.data_interpreter import DataInterpreter

di = DataInterpreter(tools=["view_page_element_to_scrape"])
await di.run("Get products from https://scrapeme.live/shop/ and save as csv")
```

### 5. Multi-Agent Debate

```python
from metagpt.team import Team
from metagpt.actions import Action
from metagpt.roles import Role
from metagpt.environment import Environment

action1 = Action(name="AlexSay", instruction="Express your opinion with emotion")
action2 = Action(name="BobSay", instruction="Express your opinion with emotion")
alex = Role(name="Alex", profile="Democrat", goal="Win", actions=[action1], watch=[action2])
bob = Role(name="Bob", profile="Republican", goal="Win", actions=[action2], watch=[action1])
env = Environment(desc="US election")
team = Team(investment=10.0, env=env, roles=[alex, bob])
await team.run(idea="Topic: climate change", send_to="Alex", n_round=5)
```

### 6. Tutorial Generation

```python
from metagpt.roles.tutorial_assistant import TutorialAssistant

role = TutorialAssistant(language="English")
await role.run("Write a tutorial about MySQL")
```

### 7. Code Review

```python
from metagpt.roles.di.engineer2 import Engineer2
from metagpt.tools.libs.cr import CodeReview

role = Engineer2(tools=["Plan", "Editor:write,read", "RoleZero", "CodeReview"])
cr = CodeReview()
role.tool_execution_map.update({"CodeReview.review": cr.review, "CodeReview.fix": cr.fix})
await role.run("Review the code in /path/to/file.py")
```

## All Available Examples

### Top-Level Examples (examples/)

| File                             | Description                                                        |
|----------------------------------|--------------------------------------------------------------------|
| hello_world.py                   | low-level LLM API demo: aask, aask_batch, streaming                |
| ping.py                          | simplest LLM test: ask "ping?" expect "pong"                       |
| debate.py                        | two Debator roles (Biden vs Trump) with custom SpeakAloud action   |
| debate_simple.py                 | simplified debate with inline actions, different models per role   |
| build_customized_agent.py        | custom Role with Actions (SimpleCoder, RunnableCoder)              |
| build_customized_multi_agents.py | three-agent pipeline: Coder -> Tester -> Reviewer                  |
| agent_creator.py                 | meta-agent that creates other agents from descriptions             |
| research.py                      | Researcher: web search, browse, summarize into report              |
| write_tutorial.py                | TutorialAssistant: generate tutorial document on any topic         |
| write_novel.py                   | ActionNode + Pydantic structured output for novel chapters         |
| write_game_code.py               | MGXEnv with TeamLeader + Engineer2 to write a 2048 game            |
| write_design.py                  | MGXEnv with TeamLeader + Architect for tech requirements           |
| use_off_the_shelf_agent.py       | built-in ProductManager to write PRD for snake game                |
| search_google.py                 | Searcher: search and summarize web results                         |
| search_with_specific_engine.py   | configure specific search engine                                   |
| search_enhanced_qa.py            | answer questions using web search results                          |
| invoice_ocr.py                   | InvoiceOCRAssistant: extract data from invoices                    |
| dalle_gpt4v_agent.py             | Painter: DALL-E 3 + GPT-4V image generation and refinement         |
| llm_vision.py                    | LLM vision capability test                                         |
| cr.py                            | code review with Engineer2 + CodeReview tool                       |
| stream_output_via_api.py         | Flask API that streams output (OpenAI-compatible endpoint)         |
| serialize_model.py               | serialization/deserialization demo                                 |
| mgx_write_project_framework.py   | full project framework generation with EnvBuilder                  |

### Data Interpreter Examples (examples/di/)

| File                            | Description                                               |
|---------------------------------|-----------------------------------------------------------|
| data_visualization.py           | data analysis on sklearn Iris with plots                  |
| machine_learning.py             | ML models (Wine dataset, Walmart sales)                   |
| crawl_webpage.py                | web scraping with view_page_element_to_scrape             |
| custom_tool.py                  | register and use custom tool functions                    |
| software_company.py             | DI-based: WritePRD -> WriteDesign -> WritePlan -> Code    |
| arxiv_reader.py                 | scrape arxiv papers, filter LLM-related, visualize        |
| use_browser.py                  | browser tool for navigating websites                      |
| fix_github_issue.py             | debug/fix GitHub issues using Editor + Terminal           |
| interacting_with_human.py       | human-in-the-loop: ask_human() and reply_to_human()       |
| machine_learning_with_tools.py  | ML with custom tool integration                           |
| email_summary.py                | email summarization and responses                         |
| ocr_receipt.py                  | receipt OCR extraction                                    |
| solve_math_problems.py          | mathematical problem solving                              |
| rm_image_background.py          | image background removal                                  |
| imitate_webpage.py              | screenshot webpage and recreate in HTML/CSS/JS            |
| run_flask.py                    | generate and run a Flask application                      |
| sd_tool_usage.py                | Stable Diffusion text-to-image                            |
| run_ml_benchmark.py             | ML benchmark tasks (Titanic, House Prices)                |
| run_open_ended_tasks.py         | open-ended tasks (OCR, scraping, games)                   |

### RAG Examples (examples/rag/)

| File            | Description                                               |
|-----------------|-----------------------------------------------------------|
| rag_pipeline.py | full RAG: FAISS/ChromaDB/Elasticsearch, add docs/objects  |
| rag_search.py   | RAG-based search                                          |
| rag_bm.py       | RAG with BM25 retrieval                                   |
| omniparse.py    | RAG with OmniParse integration                            |

### Other Example Directories

| Directory          | Description                                           |
|--------------------|-------------------------------------------------------|
| aflow/             | AFlow: automating agentic workflow generation         |
| spo/               | SPO: Self-Play Optimization                           |
| sela/              | SELA examples                                         |
| exp_pool/          | experience pool: decorator, init, load, scorer        |
| stanford_town/     | Stanford Town simulation (generative agents)          |
| werewolf_game/     | Werewolf game multi-agent simulation                  |
| android_assistant/ | Android device assistant                              |
| ui_with_chainlit/  | web UI using Chainlit framework                       |

## Advanced Usage

### Custom Actions

```python
from metagpt.actions import Action

class SimpleWriteCode(Action):
    PROMPT_TEMPLATE: str = """
    Write a python function that can {instruction}.
    Return ```python your_code_here ``` with NO other texts.
    """
    name: str = "SimpleWriteCode"

    async def run(self, instruction: str):
        prompt = self.PROMPT_TEMPLATE.format(instruction=instruction)
        rsp = await self._aask(prompt)
        return rsp
```

Inline action:

```python
action = Action(name="MySay", instruction="Express your opinion with emotion")
```

### Custom Roles

```python
from metagpt.roles.role import Role, RoleReactMode
from metagpt.schema import Message

class RunnableCoder(Role):
    name: str = "Alice"
    profile: str = "RunnableCoder"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_actions([SimpleWriteCode, SimpleRunCode])
        self._set_react_mode(react_mode=RoleReactMode.BY_ORDER.value)

    async def _act(self) -> Message:
        todo = self.rc.todo
        msg = self.get_memories(k=1)[0]
        result = await todo.run(msg.content)
        msg = Message(content=result, role=self.profile, cause_by=type(todo))
        self.rc.memory.add(msg)
        return msg
```

### React Modes

| Mode          | Description                                                           |
|---------------|-----------------------------------------------------------------------|
| REACT         | LLM dynamically selects which action to perform next (think-act loop) |
| BY_ORDER      | execute actions sequentially in the order defined in set_actions()    |
| PLAN_AND_ACT  | create a plan first, then execute tasks one by one                    |

```python
self._set_react_mode(react_mode="react", max_react_loop=10)
self._set_react_mode(react_mode="by_order")
self._set_react_mode(react_mode="plan_and_act", auto_run=True)
```

### Watch/Subscribe Pattern

Roles subscribe to Action types they care about:

```python
class SimpleTester(Role):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_actions([SimpleWriteTest])
        self._watch([SimpleWriteCode])  # triggers when SimpleWriteCode completes
```

### Directed Messages

```python
msg = Message(
    content=rsp,
    role=self.profile,
    cause_by=type(todo),
    sent_from=self.name,
    send_to="TargetRoleName",
)
```

### Custom Tools for DataInterpreter

```python
from metagpt.tools.tool_registry import register_tool

@register_tool()
def magic_function(arg1: str, arg2: int) -> dict:
    """The magic function.
    Args:
        arg1 (str): first argument
        arg2 (int): second argument
    Returns:
        dict: result
    """
    return {"arg1": arg1 * 3, "arg2": arg2 * 5}

di = DataInterpreter(tools=["magic_function"])
await di.run("Call magic_function with arg1 'A' and arg2 2")
```

### ActionNode with Pydantic Structured Output

```python
from metagpt.actions.action_node import ActionNode
from pydantic import BaseModel, Field

class Novel(BaseModel):
    name: str = Field(default="", description="The name of the novel.")
    outlines: list[str] = Field(default=[], description="Chapter outlines.")

node = await ActionNode.from_pydantic(Novel).fill(req="Write a novel", llm=LLM())
print(node.instruct_content)
```

### Per-Role LLM Configuration

In config2.yaml:

```yaml
roles:
  - role: "ProductManager"
    llm:
      api_type: "openai"
      model: "gpt-4-turbo"
  - role: "Engineer"
    llm:
      api_type: "azure"
      model: "gpt-35-turbo"
```

Programmatically:

```python
from metagpt.config2 import Config

gpt4 = Config.default()
gpt4.llm.model = "gpt-4-turbo"
action = Action(config=gpt4, name="MySay", instruction="...")
```

### Human-in-the-Loop

```python
role = SimpleReviewer(is_human=True)  # prompts human instead of LLM
```

Or using MGXEnv:

```python
env = MGXEnv()
human_rsp = await env.ask_human("What do you want to do?")
resp = await env.reply_to_human("Done")
```

### Subscription Runner

```python
from metagpt.subscription import SubscriptionRunner

async def trigger():
    while True:
        yield Message(content="the latest news about OpenAI")
        await asyncio.sleep(3600 * 24)

async def callback(msg: Message):
    print(msg.content)

pb = SubscriptionRunner()
await pb.subscribe(Searcher(), trigger(), callback)
await pb.run()
```

### Serialization / Recovery

```python
team.serialize(stg_path=Path("./storage/team"))
team = Team.deserialize(stg_path=Path("./storage/team"), context=ctx)
```

CLI:

```bash
metagpt "idea" --recover-path ./storage/team
```

### Incremental Development

```bash
metagpt "Add a leaderboard feature" --inc --project-path ./workspace/game_2048
```

## Integration Patterns

### Web API (OpenAI-compatible)

```bash
curl https://host:7860/v1/chat/completions -X POST -d '{
    "model": "write_tutorial",
    "stream": true,
    "messages": [{"role": "user", "content": "Write a tutorial about MySQL"}]
}'
```

### Chainlit UI

Web UI for interacting with MetaGPT agents, available in `examples/ui_with_chainlit/`.

### RAG (LlamaIndex)

```python
from metagpt.rag.engines import SimpleEngine
from metagpt.rag.schema import FAISSRetrieverConfig, LLMRankerConfig

engine = SimpleEngine.from_docs(
    input_files=["doc.txt"],
    retriever_configs=[FAISSRetrieverConfig()],
    ranker_configs=[LLMRankerConfig()],
)
answer = await engine.aquery("What is X?")
```

Supported backends: FAISS, ChromaDB, Elasticsearch, BM25, LLM Reranker.

### DataInterpreter Tool Integration

```python
di = DataInterpreter(tools=["Browser"])
di = DataInterpreter(tools=["Terminal", "Editor"])
di = DataInterpreter(tools=["<all>"])  # all registered tools
```

## Built-in Roles Reference

| Role                 | Profile         | Description                           |
|----------------------|-----------------|---------------------------------------|
| ProductManager       | Alice           | writes PRDs                           |
| Architect            | Bob             | writes technical design               |
| ProjectManager       | Eve             | manages tasks and schedules           |
| Engineer             | (legacy)        | legacy code implementation            |
| Engineer2            | Alex            | new engineer with DI tools            |
| QaEngineer           | Edward          | writes and runs tests                 |
| TeamLeader           | Mike            | orchestrates message routing          |
| DataAnalyst          | David           | data analysis tasks                   |
| DataInterpreter      | -               | general-purpose code agent            |
| Researcher           | -               | web research with reports             |
| TutorialAssistant    | -               | tutorial document generation          |
| InvoiceOCRAssistant  | -               | invoice data extraction               |
| Searcher             | -               | web search and summarization          |
| Sales                | -               | sales-related tasks                   |
| CustomerService      | -               | customer service agent                |
| Teacher              | -               | teaching tasks                        |
| SWEAgent             | -               | software engineering agent            |
| RoleZero             | -               | base dynamic agent with tools         |

## Built-in Actions Reference

| Action                 | Description                              |
|------------------------|------------------------------------------|
| UserRequirement        | user adds a requirement                  |
| WritePRD               | write Product Requirements Document      |
| WritePRDReview         | review PRD                               |
| WriteDesign            | write technical design / API design      |
| DesignReview           | review design                            |
| WriteCode              | write implementation code                |
| WriteCodeReview        | review code                              |
| WriteTest              | write test cases                         |
| WriteTasks             | write project management tasks           |
| RunCode                | execute code                             |
| DebugError             | debug code errors                        |
| SearchAndSummarize     | search web and summarize                 |
| CollectLinks           | collect relevant links from web search   |
| WebBrowseAndSummarize  | browse and summarize web pages           |
| ConductResearch        | conduct research from collected data     |
| ExecuteNbCode          | execute notebook code (DI)               |
| WriteAnalysisCode      | write data analysis code (DI)            |
| WritePlan              | write task plan (DI)                     |
| SearchEnhancedQA       | answer questions using web search        |
