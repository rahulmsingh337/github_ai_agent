# 🤖 GitHub AI Agents

> **8 automated GitHub Actions agents for CI/CD, security scanning, deployment monitoring, and auto-resolution.**
> Built and maintained by **Rahul Singh**

---

## Agents Overview

| Agent | Trigger | What It Does |
|-------|---------|--------------|
| 🤖 [CI Agent](.github/workflows/ci.yml) | Every push + PR | Build · lint · type check · PR comment |
| 🔧 [Auto-Fix Agent](.github/workflows/auto-fix.yml) | Manual only | Ruff + Prettier fixes, auto-commit back |
| 🔒 [Security Agent](.github/workflows/security.yml) | Weekly + dep changes | npm audit + pip-audit + issue report |
| 🔍 [PR Validator](.github/workflows/pr-validator.yml) | Every PR | Title format + secret scan + diff summary |
| 🚀 [Deployment Check](.github/workflows/deployment-check.yml) | Every push to main | Waits 90s → checks URLs → posts commit status |
| 📡 [Vercel Monitor](.github/workflows/vercel-monitor.yml) | Every push to main | Deep health check → auto-creates issue if down |
| 🛠️ [Auto-Resolve](.github/workflows/auto-resolve.yml) | When issue opened | Diagnoses error → auto-fixes → comments + closes |
| 🔧 [Error-Fix Agent](.github/workflows/error-fix.yml) | Every push | TS check + build + Python check + secret scan |

---

## Setup

### 1. Repository Permissions
Go to **Settings → Actions → General → Workflow permissions** and set:
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

### 2. Required Secrets
Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Required By | How to Get |
|--------|------------|------------|
| `VERCEL_PROJECT_URL` | Agents 5, 6 | Your Vercel app URL |
| `STAGING_URL` | Agent 5 | Your staging URL (optional) |
| `ANTHROPIC_API_KEY` | Agent 7 | [console.anthropic.com](https://console.anthropic.com) → API Keys |

> `GITHUB_TOKEN` is auto-provided — no setup needed.

### 3. Add Workflows
All 8 workflow files are in `.github/workflows/`. They activate automatically once pushed.

---

## Agent Details

### 🤖 CI Agent (`ci.yml`)
Runs on every push and PR. Executes ESLint, TypeScript compilation, Ruff (Python), and project build. On PRs, posts a formatted results table as a comment.

### 🔧 Auto-Fix Agent (`auto-fix.yml`)
Manual trigger via Actions tab. Runs `ruff --fix` and `prettier --write` across the entire codebase, then commits and pushes the changes using the `github-actions[bot]` identity.

### 🔒 Security Agent (`security.yml`)
Runs every Monday at 2 AM UTC and on every change to dependency files. Uses `npm audit` and `pip-audit` to scan for known CVEs. Creates a GitHub Issue with the full report if vulnerabilities are found.

### 🔍 PR Validator (`pr-validator.yml`)
Validates every PR against Conventional Commits format (`type(scope): description`) and scans the diff for accidentally committed secrets. Posts a validation report, updating the existing comment on re-runs.

### 🚀 Deployment Check (`deployment-check.yml`)
After every push to main, waits 90 seconds for deployment to complete, then checks your production and staging URLs. Posts the result as a commit status check (the ✅ or ❌ you see on commits).

### 📡 Vercel Monitor (`vercel-monitor.yml`)
Deep health check: validates HTTP status, SSL certificate, response time, and response body size. Auto-creates a labeled GitHub Issue if the deployment is unhealthy. Deduplicates issues per commit SHA.

### 🛠️ Auto-Resolve Agent (`auto-resolve.yml`)
Activates when an issue is opened with keywords: `bug`, `error`, `fix`, `crash`, `broken`. Uses the Anthropic Claude API to diagnose the root cause, determine if it's auto-fixable, and if so, creates a branch + PR automatically.

### 🔧 Error-Fix Agent (`error-fix.yml`)
Runs on every push. Performs TypeScript compilation check, build verification, Python syntax validation, and secret pattern scanning on changed files. Auto-applies Ruff fixes for Python errors and uploads error reports as artifacts.

---

## Conventional Commits Reference

PR titles must follow this format: `type(scope): description`

| Type | Use For |
|------|---------|
| `feat` | New features |
| `fix` | Bug fixes |
| `docs` | Documentation changes |
| `style` | Formatting only |
| `refactor` | Code restructure |
| `test` | Tests |
| `chore` | Dependencies, tooling |
| `perf` | Performance |
| `ci` | CI/CD changes |

---

## License

MIT © Rahul Singh
