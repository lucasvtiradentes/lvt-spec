# CrewAI - Usage and Examples

## Quick Start

### 1. Create a project

```bash
crewai create crew my-research-crew
cd my-research-crew
```

Generated structure:
```
my-research-crew/
├── .gitignore
├── pyproject.toml
├── README.md
├── .env
└── src/my_research_crew/
    ├── __init__.py
    ├── main.py
    ├── crew.py
    ├── tools/
    │   ├── __init__.py
    │   └── custom_tool.py
    └── config/
        ├── agents.yaml
        └── tasks.yaml
```

### 2. Configure .env

```bash
OPENAI_API_KEY=sk-...
SERPER_API_KEY=YOUR_KEY
```

### 3. Install and run

```bash
crewai install
crewai run
```

## Basic Examples

### Minimal Crew (pure Python)

```python
from crewai import Agent, Task, Crew, Process

researcher = Agent(
  role="Senior Data Researcher",
  goal="Uncover cutting-edge developments in AI",
  backstory="Seasoned researcher known for finding relevant info.",
  verbose=True,
)

writer = Agent(
  role="Content Writer",
  goal="Write engaging articles based on research findings",
  backstory="Skilled writer who turns data into stories.",
  verbose=True,
)

research_task = Task(
  description="Research the latest trends in AI agents for 2025.",
  expected_output="A list of 10 bullet points with key findings.",
  agent=researcher,
)

writing_task = Task(
  description="Write a blog post based on the research findings.",
  expected_output="A 500-word blog post in markdown format.",
  agent=writer,
  output_file="blog_post.md",
)

crew = Crew(
  agents=[researcher, writer],
  tasks=[research_task, writing_task],
  process=Process.sequential,
  verbose=True,
)

result = crew.kickoff(inputs={"topic": "AI Agents"})
print(result.raw)
print(result.token_usage)
```

### YAML-Based Declarative Crew

config/agents.yaml:
```yaml
researcher:
  role: >
    {topic} Senior Data Researcher
  goal: >
    Uncover cutting-edge developments in {topic}
  backstory: >
    Seasoned researcher with a knack for finding the latest developments.

reporting_analyst:
  role: >
    {topic} Reporting Analyst
  goal: >
    Create detailed reports based on {topic} data analysis
  backstory: >
    Meticulous analyst known for turning complex data into clear reports.
```

config/tasks.yaml:
```yaml
research_task:
  description: >
    Conduct thorough research about {topic}.
  expected_output: >
    A list with 10 bullet points of relevant information about {topic}.
  agent: researcher

reporting_task:
  description: >
    Review the context and expand each topic into a full report section.
  expected_output: >
    A detailed report in markdown format.
  agent: reporting_analyst
  output_file: report.md
```

crew.py:
```python
from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task

@CrewBase
class MyResearchCrew():

  @agent
  def researcher(self) -> Agent:
    return Agent(config=self.agents_config['researcher'], verbose=True)

  @agent
  def reporting_analyst(self) -> Agent:
    return Agent(config=self.agents_config['reporting_analyst'], verbose=True)

  @task
  def research_task(self) -> Task:
    return Task(config=self.tasks_config['research_task'])

  @task
  def reporting_task(self) -> Task:
    return Task(config=self.tasks_config['reporting_task'], output_file='report.md')

  @crew
  def crew(self) -> Crew:
    return Crew(agents=self.agents, tasks=self.tasks, process=Process.sequential, verbose=True)
```

main.py:
```python
from my_research_crew.crew import MyResearchCrew

def run():
  MyResearchCrew().crew().kickoff(inputs={'topic': 'AI Agents'})
```

### Hierarchical Process

```python
crew = Crew(
  agents=[researcher, writer, analyst],
  tasks=[research_task, writing_task, analysis_task],
  process=Process.hierarchical,
  manager_llm="openai/gpt-4o",
  verbose=True,
)
```

With custom manager:
```python
manager = Agent(
  role="Project Manager",
  goal="Coordinate the team effectively",
  backstory="Experienced project lead",
  allow_delegation=True,
)

crew = Crew(
  agents=[researcher, writer],
  tasks=[research_task, writing_task],
  process=Process.hierarchical,
  manager_agent=manager,
  verbose=True,
)
```

## LLM Configuration

```python
from crewai import Agent, LLM

llm = LLM(model="gpt-4o", temperature=0.7, max_tokens=4000)
llm = LLM(model="anthropic/claude-3-sonnet-20240229")
llm = LLM(model="google/gemini-2.0-flash")
llm = LLM(model="ollama/llama3", base_url="http://localhost:11434")
llm = LLM(model="azure/gpt-4o", api_key="...", base_url="https://your-resource.openai.azure.com/")

agent = Agent(role="Analyst", goal="Analyze", backstory="Expert", llm=llm)
```

String shorthand also works: `llm="openai/gpt-4o"`.

## Structured Output

```python
from pydantic import BaseModel

class ResearchOutput(BaseModel):
  title: str
  findings: list[str]
  confidence: float

task = Task(
  description="Research AI agents",
  expected_output="Structured research output",
  output_pydantic=ResearchOutput,
  agent=researcher,
)

result = crew.kickoff()
print(result.pydantic)
print(result.json_dict)
print(result.raw)
```

## Task Guardrails

Callable guardrail:
```python
from crewai.tasks.task_output import TaskOutput

def validate_output(output: TaskOutput) -> tuple[bool, str]:
  if len(output.raw) < 100:
    return (False, "Output too short, needs more detail")
  return (True, output.raw)

task = Task(
  description="Write detailed report",
  expected_output="Comprehensive report",
  agent=writer,
  guardrail=validate_output,
  guardrail_max_retries=3,
)
```

LLM-based string guardrail:
```python
task = Task(
  description="Write report",
  expected_output="Report",
  agent=writer,
  guardrail="Ensure output contains at least 3 data points and is factually accurate",
)
```

Multiple guardrails:
```python
task = Task(
  description="Write report",
  expected_output="Report",
  agent=writer,
  guardrails=[validate_output, "Ensure professional tone throughout"],
  guardrail_max_retries=3,
)
```

## Conditional Tasks

```python
from crewai.tasks.conditional_task import ConditionalTask

def should_run_deep_analysis(output: TaskOutput) -> bool:
  return "complex" in output.raw.lower()

deep_analysis = ConditionalTask(
  description="Perform deep analysis",
  expected_output="Detailed analysis report",
  agent=researcher,
  condition=should_run_deep_analysis,
)

crew = Crew(
  agents=[researcher, writer],
  tasks=[research_task, deep_analysis, writing_task],
  process=Process.sequential,
)
```

## Task Context

```python
research_task = Task(description="Research {topic}", expected_output="Findings", agent=researcher)

analysis_task = Task(
  description="Analyze the research",
  expected_output="Analysis report",
  agent=analyst,
  context=[research_task],
)
```

## Async Execution

```python
result = await crew.kickoff_async(inputs={"topic": "AI"})
result = await crew.akickoff(inputs={"topic": "AI"})

results = await crew.kickoff_for_each_async(
  inputs=[{"topic": "AI"}, {"topic": "ML"}, {"topic": "NLP"}]
)
```

## Streaming

```python
crew = Crew(agents=[researcher], tasks=[task], stream=True)

streaming_output = crew.kickoff(inputs={"topic": "AI"})
for chunk in streaming_output:
  print(chunk, end="", flush=True)
final_result = streaming_output.result
```

## Memory

```python
crew = Crew(
  agents=[...],
  tasks=[...],
  memory=True,
  embedder={"provider": "openai", "config": {"model": "text-embedding-3-small"}},
)
```

Reset:
```bash
crewai reset-memories --all
crewai reset-memories --short --long --entities
```

## Knowledge

```python
from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource

content = "User name is John. He is 30 years old."
string_source = StringKnowledgeSource(content=content)

agent = Agent(
  role="About User",
  goal="Know everything about the user",
  backstory="Master at understanding people",
  knowledge_sources=[string_source],
)
```

Crew-level knowledge:
```python
crew = Crew(
  agents=[agent],
  tasks=[task],
  knowledge_sources=[string_source],
  embedder={"provider": "openai", "config": {"model": "text-embedding-3-small"}},
)
```

## Flows

### Basic Flow

```python
from crewai.flow.flow import Flow, listen, start
from pydantic import BaseModel

class MyState(BaseModel):
  counter: int = 0
  data: str = ""

class MyFlow(Flow[MyState]):
  @start()
  def begin(self):
    self.state.counter = 1
    return "started"

  @listen(begin)
  def process(self, result):
    self.state.data = f"Processed: {result}"
    return self.state.data

flow = MyFlow()
result = flow.kickoff()
```

### Flow with Router

```python
from crewai.flow.flow import Flow, start, listen, router, or_

class AnalysisFlow(Flow):
  @start()
  def fetch_data(self):
    return {"sector": "tech"}

  @listen(fetch_data)
  def analyze(self, data):
    crew = Crew(agents=[analyst], tasks=[analysis_task])
    return crew.kickoff(inputs=data)

  @router(analyze)
  def determine_next(self):
    if self.state.confidence > 0.8:
      return "high_confidence"
    return "low_confidence"

  @listen("high_confidence")
  def execute_strategy(self):
    return "Executing strategy"

  @listen("low_confidence")
  def request_more_data(self):
    return "Need more data"
```

### Flow Conditions

```python
from crewai.flow.flow import or_, and_

@listen(or_("method1", "method2"))
def runs_when_any_completes(self):
  pass

@listen(and_("method1", "method2"))
def runs_when_all_complete(self):
  pass
```

## MCP Integration

```python
from crewai.mcp import MCPServerStdio, MCPServerSSE, MCPServerHTTP

agent = Agent(
  role="Researcher",
  goal="Research topics",
  backstory="Expert researcher",
  mcps=[
    MCPServerStdio(command="npx", args=["-y", "@modelcontextprotocol/server-filesystem"]),
    MCPServerSSE(url="http://localhost:8080/sse"),
    MCPServerHTTP(url="http://localhost:8080"),
  ],
)
```

## Custom Tools

Function decorator:
```python
from crewai.tools import tool

@tool("My Search Tool")
def my_search(query: str) -> str:
  """Searches for information on a topic."""
  return f"Results for: {query}"

agent = Agent(role="...", goal="...", backstory="...", tools=[my_search])
```

Class-based:
```python
from crewai.tools.base_tool import BaseTool

class MySearchTool(BaseTool):
  name: str = "Custom Search"
  description: str = "Searches the web for information"

  def _run(self, query: str) -> str:
    return f"Results for {query}"
```

## Agent Features

Standalone agent execution:
```python
agent = Agent(role="...", goal="...", backstory="...")
result = agent.kickoff(messages="What is AI?")
```

Reasoning mode:
```python
agent = Agent(role="...", goal="...", backstory="...", reasoning=True, max_reasoning_attempts=3)
```

Code execution:
```python
agent = Agent(
  role="Coder",
  goal="Execute code",
  backstory="Expert coder",
  allow_code_execution=True,
  code_execution_mode="safe",
)
```

## Planning Mode

```python
crew = Crew(
  agents=[...],
  tasks=[...],
  planning=True,
  planning_llm="gpt-4o",
)
```

## Callbacks

Task callback:
```python
def my_callback(output):
  print(f"Task completed: {output.raw[:100]}")

task = Task(description="...", expected_output="...", agent=agent, callback=my_callback)
```

Crew lifecycle:
```python
@CrewBase
class MyCrew():
  @before_kickoff
  def prepare(self, inputs):
    inputs['extra'] = 'data'
    return inputs

  @after_kickoff
  def post_process(self, result):
    print(f"Done: {len(result.raw)} chars")
    return result
```

## Training and Testing

```bash
crewai train -n 5
crewai test -n 3 -m gpt-4o-mini
```

## CLI Reference

| Command                       | Description                                    |
|-------------------------------|------------------------------------------------|
| crewai create crew <name>     | Scaffold new crew project                      |
| crewai create flow <name>     | Scaffold new flow project                      |
| crewai run                    | Run the crew                                   |
| crewai install                | Install dependencies                           |
| crewai version                | Show version                                   |
| crewai chat                   | Interactive conversation with crew             |
| crewai train -n 5             | Train crew for 5 iterations                    |
| crewai test -n 3              | Test crew for 3 iterations                     |
| crewai replay -t <task_id>    | Replay from specific task                      |
| crewai reset-memories -a      | Reset all memories                             |
| crewai flow kickoff           | Run a flow                                     |
| crewai flow plot              | Visualize flow graph                           |
| crewai flow add-crew <name>   | Add crew to existing flow                      |
| crewai deploy create          | Create deployment                              |
| crewai deploy push            | Push to deployment                             |
| crewai deploy list            | List deployments                               |
| crewai deploy status          | Check deployment status                        |
| crewai deploy logs            | View deployment logs                           |
| crewai deploy remove          | Remove deployment                              |
| crewai tool create <handle>   | Create tool in repository                      |
| crewai tool install <handle>  | Install tool from repository                   |
| crewai tool publish           | Publish tool                                   |
| crewai login                  | Authenticate with CrewAI AMP                   |
| crewai traces enable          | Enable trace collection                        |
| crewai traces disable         | Disable trace collection                       |
| crewai traces status          | Show trace status                              |
| crewai org list               | List organizations                             |
| crewai org switch <id>        | Switch organization                            |
| crewai config list            | List CLI config                                |
| crewai config set <k> <v>     | Set CLI config                                 |
| crewai env view               | View tracing env vars                          |
| crewai log-tasks-outputs      | Show latest task outputs                       |

## CrewOutput Structure

```python
result = crew.kickoff(inputs={"topic": "AI"})

result.raw           # str: raw output of last task
result.pydantic      # BaseModel | None: if output_pydantic set
result.json_dict     # dict | None: if output_json set
result.tasks_output  # list[TaskOutput]: all task outputs
result.token_usage   # UsageMetrics: total/prompt/completion tokens
```

TaskOutput:
```python
task_output.raw           # str: raw result
task_output.pydantic      # BaseModel | None
task_output.json_dict     # dict | None
task_output.description   # str: task description
task_output.agent         # str: agent role
task_output.output_format # OutputFormat: RAW/JSON/PYDANTIC
task_output.messages      # list: LLM messages from execution
```

## Built-in Tools (70+)

| Category       | Tools                                                                  |
|----------------|------------------------------------------------------------------------|
| Search         | SerperDevTool, BraveSearchTool, EXASearchTool, TavilySearchTool        |
| Scraping       | ScrapeWebsiteTool, FirecrawlScrapeWebsiteTool, SeleniumScrapingTool    |
| Files          | FileReadTool, FileWriterTool, DirectoryReadTool, FileCompressorTool    |
| Documents      | PDFSearchTool, DOCXSearchTool, CSVSearchTool, JSONSearchTool           |
| Code           | CodeInterpreterTool, CodeDocsSearchTool, GithubSearchTool              |
| Databases      | MySQLSearchTool, NL2SQLTool, SnowflakeSearchTool, DatabricksQueryTool  |
| AI/ML          | DallETool, VisionTool, OCRTool, LlamaIndexTool                         |
| AWS            | S3ReaderTool, S3WriterTool, BedrockInvokeAgentTool                     |
| YouTube        | YoutubeVideoSearchTool, YoutubeChannelSearchTool                       |
| Integrations   | ComposioTool, ZapierActionTool, ApifyActorsTool, MCPServerAdapter      |
| Vector Search  | QdrantVectorSearchTool, WeaviateVectorSearchTool, MongoDBVectorSearch  |

Install with: `pip install 'crewai[tools]'`

## Observability

Enable tracing:
```python
crew = Crew(..., tracing=True)
```

Or via CLI:
```bash
crewai traces enable
```

Supported integrations: Arize Phoenix, Braintrust, Datadog, Galileo, LangDB, Langfuse, Langtrace, Maxim, MLflow, NeatLogs, OpenLit, Opik, Patronus, Portkey, TrueFoundry, Weave.

## Event System

```python
from crewai.events.event_bus import crewai_event_bus
from crewai.events.types.task_events import TaskCompletedEvent

@crewai_event_bus.on(TaskCompletedEvent)
def on_task_completed(source, event):
  print(f"Task completed: {event.task.description}")
```

40+ event types covering crew, task, agent, LLM, tool, flow, memory, knowledge, MCP, A2A, reasoning, and guardrail lifecycle.
