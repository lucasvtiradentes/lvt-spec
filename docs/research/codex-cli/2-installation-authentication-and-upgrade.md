# Installation Authentication and Upgrade

## Prerequisites

| Requirement| Minimum                         | Check           |
|------------|---------------------------------|-----------------|
| Node.js    | Current LTS recommended         | `node --version`|
| npm        | Bundled with Node.js            | `npm --version` |
| Git        | Required for most repo workflows| `git --version` |

## Install and First Run

| Action                | Command                                         |
|-----------------------|-------------------------------------------------|
| Install globally      | `npm install -g @openai/codex`                  |
| Open help             | `codex --help`                                  |
| Start interactive mode| `codex`                                         |
| Run one-shot task     | `codex exec "explain this repository structure"`|

## Authentication Paths

| Method                   | Command                         | When To Use                      |
|--------------------------|---------------------------------|----------------------------------|
| API key via login command| `printenv OPENAI_API_KEY        | codex login --with-api-key`      | CI, scripting, explicit key control|
| Interactive login        | `codex --login` or `codex login`| Local developer setup            |
| Status check             | `codex login status`            | Confirm authenticated identity   |
| Logout                   | `codex logout`                  | Rotate credentials or reset state|

## Common Auth Problems

| Symptom                         | Likely Cause                          | Fix                                             |
|---------------------------------|---------------------------------------|-------------------------------------------------|
| Unauthorized/forbidden          | Invalid or expired credential         | `codex logout` then login again                 |
| Login succeeds but requests fail| Wrong environment/profile             | verify `~/.codex/config.toml` and active profile|
| API key not picked up           | Variable not exported in shell session| `export OPENAI_API_KEY=...` then retry          |

## Upgrade and Maintenance

| Action          | Command                              |
|-----------------|--------------------------------------|
| Built-in upgrade| `codex --upgrade`                    |
| npm fallback    | `npm install -g @openai/codex@latest`|
| Version audit   | `codex --version`                    |

Recommended maintenance loop:

1. Check version before long work sessions
2. Re-auth if behavior is inconsistent after updates
3. Validate `codex --help` for new/changed flags
