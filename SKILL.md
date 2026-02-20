---
name: publish-skill
description: Package and publish an OpenClaw skill to GitHub and ClawhHub. Use when asked to "publish a skill", "open source a skill", "upload skill to GitHub", or "release a skill". Handles GitHub repo creation, file upload via API, and ClawhHub publishing. Requires gh CLI (already authenticated) and clawhub CLI (run clawhub login first).
---

# Publish Skill

Package and publish an OpenClaw skill to GitHub and/or ClawhHub.

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- `clawhub` CLI logged in (`clawhub login`) — only needed for ClawhHub publishing

## Workflow

### Step 1 — Prepare the skill

Before publishing, ensure the skill is compliant:

```bash
python3 ~/.openclaw/workspace/skills/skill-refiner/scripts/audit_skill.py <skill-dir>
```

Fix any issues before proceeding.

### Step 2 — Add required files for open-source release

The skill directory should have:
- `SKILL.md` — skill definition (required)
- `README.md` — English documentation
- `README.zh.md` — Chinese documentation (bilingual standard)
- `LICENSE` — MIT recommended
- `package.json` — if supporting `npx` installation

**README template** (both languages should include):
1. What the skill does
2. Quick start / installation (`clawhub install <name>` + `npx <name>`)
3. What it checks/does (table format)
4. Example output
5. License

**package.json template for npx support:**
```json
{
  "name": "<skill-name>",
  "version": "1.0.0",
  "description": "<description>",
  "bin": { "<skill-name>": "./bin/<skill-name>.sh" },
  "files": ["bin/", "scripts/", "SKILL.md", "README.md", "README.zh.md"],
  "license": "MIT",
  "repository": { "type": "git", "url": "https://github.com/<owner>/<skill-name>.git" }
}
```

### Step 3 — Publish to GitHub

```bash
bash scripts/publish_to_github.sh <skill-dir> <github-owner> [description]
```

This uses `gh api` (no `git push` needed — avoids auth prompts).

### Step 4 — Publish to ClawhHub

```bash
bash scripts/publish_to_clawhub.sh <skill-dir> [version] [changelog]
```

Requires `clawhub login` first. Token is stored in `~/Library/Application Support/clawhub/config.json`.

### Step 5 — Verify

- GitHub: `gh repo view <owner>/<skill-name>`
- ClawhHub: `clawhub search <skill-name>`

## GitHub Owner

Default owner: `1va7` (VA7's GitHub account, already authenticated via `gh` CLI keyring)

## Notes

- Never put credentials directly in skill files
- GitHub token is stored in macOS keyring (managed by `gh auth`)
- ClawhHub token is stored in `~/Library/Application Support/clawhub/config.json`
- Use `gh api` for file uploads instead of `git push` to avoid interactive auth prompts
