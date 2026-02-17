# Installation Authentication and Upgrade

## Prerequisites

| Requirement      | Minimum                                                 | Check             |
|------------------|---------------------------------------------------------|-------------------|
| Operating System | macOS 13.0+, Windows 10 1809+, Ubuntu 20.04+, Debian 10+| -                 |
| RAM              | 4 GB+                                                   | -                 |
| Network          | Internet connection                                     | -                 |
| Shell            | Bash or Zsh recommended                                 | -                 |
| Node.js          | v18+ (only for npm method)                              | `node --version`  |
| Location         | Anthropic supported countries                           | -                 |

## Installation Methods

| Method               | Platform           | Command / Action                                                                           |
|----------------------|--------------------|--------------------------------------------------------------------------------------------|
| Native (recommended) | macOS, Linux, WSL  | `curl -fsSL https://claude.ai/install.sh \| bash`                                          |
| Native               | Windows PowerShell | `irm https://claude.ai/install.ps1 \| iex`                                                 |
| Native               | Windows CMD        | `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd`|
| Homebrew             | macOS              | `brew install --cask claude-code`                                                          |
| WinGet               | Windows            | `winget install Anthropic.ClaudeCode`                                                      |
| npm (deprecated)     | All                | `npm install -g @anthropic-ai/claude-code`                                                 |

Native installation auto-updates in background. Homebrew/WinGet require manual updates.

Windows native requires Git Bash from Git for Windows. WSL 2 supports sandboxing; WSL 1 has limited support.

## First Run

| Action                        | Command                      |
|-------------------------------|------------------------------|
| Navigate to project           | `cd your-project`            |
| Start Claude Code             | `claude`                     |
| Check installation health     | `claude doctor`              |

## Authentication Paths

| Method                       | Target                           | When To Use                          |
|------------------------------|----------------------------------|--------------------------------------|
| Claude Pro/Max subscription  | claude.ai account                | Personal use, unified billing        |
| Claude for Teams/Enterprise  | claude.ai account                | Team use, centralized management     |
| Claude Console OAuth         | console.anthropic.com            | API-based billing, pay-as-you-go     |
| Amazon Bedrock               | AWS credentials                  | Enterprise cloud infrastructure      |
| Google Vertex AI             | GCP credentials                  | Enterprise cloud infrastructure      |
| Microsoft Foundry            | Azure credentials                | Enterprise cloud infrastructure      |

API keys and OAuth tokens stored in encrypted macOS Keychain (on macOS).

To use subscription instead of API key, unset `ANTHROPIC_API_KEY` environment variable.

## Authentication Commands

| Action                    | Command                                           |
|---------------------------|---------------------------------------------------|
| Login                     | `claude`                                          |
| Logout                    | `/logout` or `claude logout`                      |
| Setup OAuth token         | `claude setup-token`                              |
| Force re-authentication   | `rm -rf ~/.config/claude-code/auth.json && claude`|

If browser does not open during login, press `c` to copy OAuth URL to clipboard.

## Common Auth Problems and Fixes

| Problem                              | Cause                                  | Fix                                                         |
|--------------------------------------|----------------------------------------|-------------------------------------------------------------|
| Invalid API key error                | Wrong key or extra spaces/chars        | Verify key in Anthropic Console                             |
| OAuth flow succeeds but auth fails   | Config file save/read issue            | Remove auth.json and re-login                               |
| Browser does not open                | System browser config issue            | Press `c` to copy URL, paste in browser                     |
| Repeated permission prompts          | Tools not allowlisted                  | Use `/permissions` to allow tools                           |
| Using API key instead of subscription| ANTHROPIC_API_KEY env var set          | Unset the env var or run `claude logout` then `claude login`|
| Pro subscription not recognized      | Cookie/session issue                   | Clear browser cookies, use incognito                        |

## Upgrade and Maintenance

| Action                    | Command / Method                                           |
|---------------------------|------------------------------------------------------------|
| Check version             | `claude doctor`                                            |
| Manual update             | `claude update`                                            |
| Update Homebrew install   | `brew upgrade claude-code`                                 |
| Update WinGet install     | `winget upgrade Anthropic.ClaudeCode`                      |
| Disable auto-updates      | `export DISABLE_AUTOUPDATER=1`                             |
| Install specific version  | `curl -fsSL https://claude.ai/install.sh \| bash -s 1.0.58`|
| Install stable channel    | `curl -fsSL https://claude.ai/install.sh \| bash -s stable`|

Native installs auto-update in background. Updates check on startup and periodically while running.

## Release Channels

| Channel  | Description                                      |
|----------|--------------------------------------------------|
| latest   | New features as soon as released (default)       |
| stable   | ~1 week old version, skips major regressions     |

Configure via `/config` or add to settings.json:
```json
{
  "autoUpdatesChannel": "stable"
}
```

## Migrate npm to Native

Run `claude install` to migrate existing npm installation to native installer.

## Uninstall

| Installation Method | Command                                                            |
|---------------------|--------------------------------------------------------------------|
| Native (macOS/Linux)| `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`        |
| Native (Windows)    | `Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force`|
| Homebrew            | `brew uninstall --cask claude-code`                                |
| WinGet              | `winget uninstall Anthropic.ClaudeCode`                            |
| npm                 | `npm uninstall -g @anthropic-ai/claude-code`                       |

## Sources

- https://code.claude.com/docs/en/setup
- https://code.claude.com/docs/en/authentication
- https://code.claude.com/docs/en/troubleshooting
- https://support.claude.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan
