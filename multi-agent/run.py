import sys
import json
import os
import subprocess


def call_claude_code(model, system_prompt, messages):
    conversation = '\n\n'.join(m['content'] for m in messages)
    full_prompt = f'{system_prompt}\n\n---\n\n{conversation}'
    result = subprocess.run(
        ['claude', '-p', full_prompt, '--model', model],
        capture_output=True,
        text=True,
        timeout=300,
    )
    if result.returncode != 0:
        raise RuntimeError(f'claude CLI failed: {result.stderr}')
    return result.stdout.strip()


def call_anthropic(model, system_prompt, messages):
    import anthropic
    client = anthropic.Anthropic()
    resp = client.messages.create(
        model=model,
        max_tokens=1024,
        system=system_prompt,
        messages=messages,
    )
    return resp.content[0].text


def call_openai(model, system_prompt, messages):
    import openai
    client = openai.OpenAI()
    msgs = [{'role': 'system', 'content': system_prompt}] + messages
    resp = client.chat.completions.create(model=model, messages=msgs)
    return resp.choices[0].message.content


def call_gemini(model, system_prompt, messages):
    from google import genai
    from google.genai import types
    client = genai.Client()
    contents = []
    for m in messages:
        role = 'user' if m['role'] == 'user' else 'model'
        contents.append(types.Content(role=role, parts=[types.Part.from_text(text=m['content'])]))
    resp = client.models.generate_content(
        model=model,
        contents=contents,
        config=types.GenerateContentConfig(system_instruction=system_prompt),
    )
    return resp.text


PROVIDERS = {
    'claude-code': call_claude_code,
    'anthropic': call_anthropic,
    'openai': call_openai,
    'gemini': call_gemini,
}


def call_llm(provider, model, system_prompt, messages):
    fn = PROVIDERS.get(provider)
    if not fn:
        raise ValueError(f'Unknown provider: {provider}. Available: {", ".join(PROVIDERS.keys())}')
    return fn(model, system_prompt, messages)


def load_config(config_path):
    with open(config_path) as f:
        config = json.load(f)
    base_dir = os.path.dirname(os.path.abspath(config_path))
    agents = []
    for a in config['agents']:
        md_path = os.path.join(base_dir, a['file'])
        with open(md_path) as f:
            system_prompt = f.read().strip()
        agents.append({
            'name': a['name'],
            'provider': a['provider'],
            'model': a['model'],
            'system_prompt': system_prompt,
        })
    return config['max_rounds'], agents


def run(config_path, prompt):
    max_rounds, agents = load_config(config_path)
    messages = [{'role': 'user', 'content': prompt}]

    print(f'\n{"=" * 60}')
    print(f'  MULTI-AGENT COLLABORATION')
    print(f'  Agents: {", ".join(a["name"] for a in agents)}')
    print(f'  Rounds: {max_rounds}')
    print(f'  Prompt: {prompt[:80]}{"..." if len(prompt) > 80 else ""}')
    print(f'{"=" * 60}')

    for round_num in range(1, max_rounds + 1):
        print(f'\n{"─" * 60}')
        print(f'  ROUND {round_num}/{max_rounds}')
        print(f'{"─" * 60}')

        for agent in agents:
            print(f'\n>>> {agent["name"]} ({agent["provider"]}/{agent["model"]})')
            print()

            if round_num == 1:
                turn_instruction = f'You are {agent["name"]}. Analyze the requirement above and contribute your perspective. Other agents will follow.'
            else:
                turn_instruction = f'You are {agent["name"]}. This is round {round_num}/{max_rounds}. Review the discussion so far, address open questions raised by other agents, make concrete decisions, and converge toward a final actionable plan. Do NOT ask the user for clarification — decide based on what the team discussed.'

            turn_messages = messages + [{'role': 'user', 'content': turn_instruction}]
            response = call_llm(agent['provider'], agent['model'], agent['system_prompt'], turn_messages)
            print(response)
            messages.append({
                'role': 'user',
                'content': f'[{agent["name"]}]: {response}',
            })

    last = agents[-1]
    print(f'\n{"=" * 60}')
    print(f'  FINAL SUMMARY (by {last["name"]})')
    print(f'{"=" * 60}\n')
    messages.append({
        'role': 'user',
        'content': 'Based on the entire collaboration above, write a final consolidated summary with: 1) agreed decisions, 2) key deliverables, 3) open questions. Be thorough.',
    })
    summary = call_llm(last['provider'], last['model'], last['system_prompt'], messages)
    print(summary)


def main():
    args = sys.argv[1:]
    config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config.json')

    if '--config' in args:
        idx = args.index('--config')
        config_path = args[idx + 1]
        args = args[:idx] + args[idx + 2:]

    prompt = ' '.join(args)
    if not prompt:
        print('Usage: python run.py [--config path/to/config.json] "your prompt here"')
        print()
        print('Examples:')
        print('  python run.py "design an authentication screen for a new system"')
        print('  python run.py --config my-config.json "build a REST API for todo app"')
        print()
        print('Providers:')
        print('  claude-code - uses claude CLI (Claude Max OAuth, no API key needed)')
        print('  anthropic   - uses ANTHROPIC_API_KEY')
        print('  openai      - uses OPENAI_API_KEY')
        print('  gemini      - uses GEMINI_API_KEY or GOOGLE_API_KEY')
        sys.exit(1)

    run(config_path, prompt)


if __name__ == '__main__':
    main()
