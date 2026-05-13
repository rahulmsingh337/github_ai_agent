# 🤖 GitHub AI Agents

<div align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-8_Agents-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Automated-00C853?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Scanning-DC2626?style=for-the-badge)
![Auto Resolve](https://img.shields.io/badge/Auto_Resolve-AI_Powered-9333EA?style=for-the-badge)

**A complete suite of 8 GitHub Actions agents that automate your entire CI/CD pipeline —
from code quality and security scanning to deployment monitoring and AI-powered bug resolution.**

*Built and maintained by **Rahul Singh***

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Agent Reference](#-agent-reference)
- [How It All Works Together](#-how-it-all-works-together)
- [Setup Guide](#-setup-guide)
- [Agent Deep-Dives](#-agent-deep-dives)
- [Secrets Reference](#-secrets-reference)
- [Conventional Commits](#-conventional-commits-format)
- [Troubleshooting](#-troubleshooting)
- [Architecture](#-architecture)

---

## 🗺 Overview

This repository contains **8 production-ready GitHub Actions workflows** that collectively create a self-healing, self-monitoring codebase. Each agent operates independently but they are designed to complement each other.

```
Every Push ──────────► 🤖 CI Agent          (lint + typecheck + build)
                   ──► 🔧 Error-Fix Agent    (TS + Python + secret scan)
                   ──► 🚀 Deployment Check   (URL health + commit status)
                   ──► 📡 Vercel Monitor     (deep health + auto-issue)

Every PR   ──────────► 🤖 CI Agent          (+ posts PR comment)
                   ──► 🔍 PR Validator       (title format + secret scan)

dep changes ─────────► 🔒 Security Agent    (CVE scan + issue report)
Every Monday ────────► 🔒 Security Agent    (scheduled CVE scan)

Issue Opened ────────► 🛠️ Auto-Resolve      (AI diagnosis + auto-PR)

Manual ──────────────► 🔧 Auto-Fix Agent    (format + commit back)
```

---

## 📊 Agent Reference

| # | Agent | File | Trigger | What It Does |
|---|-------|------|---------|--------------|
| 1 | 🤖 CI Agent | [`ci.yml`](.github/workflows/ci.yml) | Every push + PR | ESLint · TypeScript · Ruff · Build · PR comment |
| 2 | 🔧 Auto-Fix | [`auto-fix.yml`](.github/workflows/auto-fix.yml) | Manual only | Ruff + Prettier auto-fix, commits back to branch |
| 3 | 🔒 Security | [`security.yml`](.github/workflows/security.yml) | Weekly + dep changes | npm audit + pip-audit + opens GitHub issue |
| 4 | 🔍 PR Validator | [`pr-validator.yml`](.github/workflows/pr-validator.yml) | Every PR | Conventional commits + secret scan + diff summary |
| 5 | 🚀 Deployment Check | [`deployment-check.yml`](.github/workflows/deployment-check.yml) | Push to main | Waits 90s → checks prod + staging → commit status |
| 6 | 📡 Vercel Monitor | [`vercel-monitor.yml`](.github/workflows/vercel-monitor.yml) | Push to main | HTTP + SSL + body check → auto-creates incident issue |
| 7 | 🛠️ Auto-Resolve | [`auto-resolve.yml`](.github/workflows/auto-resolve.yml) | Issue opened | Claude AI diagnosis → auto-branch + PR if fixable |
| 8 | 🔧 Error-Fix | [`error-fix.yml`](.github/workflows/error-fix.yml) | Every push | TS + build + Python + secret scan + annotations |

---

## 🔄 How It All Works Together

### A push to `main` triggers:

```
Developer pushes commit
        │
        ├──► 🤖 CI Agent
        │       ├── ESLint (JS/TS)
        │       ├── tsc --noEmit (TypeScript)
        │       ├── ruff check (Python)
        │       └── npm run build
        │
        ├──► 🔧 Error-Fix Agent
        │       ├── TypeScript compilation check + annotations
        │       ├── Build verification
        │       ├── Python syntax check
        │       ├── Secret pattern scan (changed files only)
        │       └── Auto-apply Ruff fixes if Python fails
        │
        ├──► 🚀 Deployment Check  (waits 90s)
        │       ├── curl production URL
        │       ├── curl staging URL
        │       └── POST commit status ✅ or ❌
        │
        └──► 📡 Vercel Monitor  (waits 60s)
                ├── HTTP status + response time
                ├── SSL certificate validation
                ├── Response body size check
                └── Auto-create GitHub Issue if unhealthy
```

### A PR opened/updated triggers:

```
PR opened or synchronized
        │
        ├──► 🤖 CI Agent  (same checks + PR comment with results table)
        │
        └──► 🔍 PR Validator
                ├── Title matches Conventional Commits? ✅/❌
                ├── Diff scanned for secrets/API keys
                ├── Changed files + stat summary
                └── Posts/updates validation comment on PR
```

### A GitHub Issue opened triggers:

```
Issue: "Error: cannot read property 'id' of undefined"
        │
        └──► 🛠️ Auto-Resolve Agent
                ├── Posts "investigating..." comment
                ├── Gathers source files + recent commits
                ├── Calls Claude API for diagnosis
                ├── fixable=true  → creates branch + PR + comments link
                └── fixable=false → comments diagnosis + manual steps
```

---

## ⚙️ Setup Guide

### Step 1 — Repository Permissions

> **Settings → Actions → General → Workflow permissions**

- ✅ **Read and write permissions**
- ✅ **Allow GitHub Actions to create and approve pull requests**

### Step 2 — Add Secrets

> **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Required | Used By | How to Get |
|--------|----------|---------|------------|
| `GITHUB_TOKEN` | Auto | All | Injected automatically — do nothing |
| `VERCEL_PROJECT_URL` | Optional | Agents 5, 6 | Your live URL e.g. `https://your-app.vercel.app` |
| `STAGING_URL` | Optional | Agent 5 | Your staging URL |
| `ANTHROPIC_API_KEY` | Optional | Agent 7 | [console.anthropic.com](https://console.anthropic.com) → API Keys |

> Agents 5 and 6 skip gracefully without `VERCEL_PROJECT_URL`.
> Agent 7 posts a manual-review comment without `ANTHROPIC_API_KEY`.

### Step 3 — Push any commit

All agents activate automatically. No further config needed.

---

## 🔬 Agent Deep-Dives

### 🤖 CI Agent

**Trigger:** Every `push` and `pull_request`

Runs ESLint, `tsc --noEmit`, Ruff, and `npm run build` in parallel with `continue-on-error: true` so all checks complete even if one fails. On PRs, posts a formatted results table as a comment — and updates it in place on subsequent pushes.

---

### 🔧 Auto-Fix Agent

**Trigger:** Manual (`workflow_dispatch`)

Triggered from the **Actions tab → Run workflow**. Runs `ruff check --fix`, `ruff format`, and `prettier --write` across the whole codebase, then commits back using `github-actions[bot]` identity. Skips the commit if no files changed.

---

### 🔒 Security Agent

**Trigger:** Every Monday 2 AM UTC + push when `package.json` / `requirements.txt` / `pyproject.toml` change

Runs `npm audit` and `pip-audit` against the GitHub Advisory Database and PyPA Advisory Database respectively. If any vulnerabilities are found, automatically opens a GitHub Issue labeled `security` + `automated` with full counts and remediation commands.

---

### 🔍 PR Validator Agent

**Trigger:** PR `opened`, `synchronize`, `reopened`, `edited`

**Check 1 — Conventional Commits:** Title must match `type(scope): description`.

```
feat(auth): add OAuth2 login         ✅
fix(api): handle null payment resp   ✅
Updated login page                   ❌
```

**Check 2 — Secret scan:** Scans the full diff for API key patterns. Shows 🚨 BLOCKED if found.

Updates its existing comment on re-runs instead of creating new ones.

---

### 🚀 Deployment Check Agent

**Trigger:** Push to `main` only

Waits 90 seconds for deployment, then checks both production and staging URLs via `curl`. Posts the result as a **commit status check** — the ✅/❌ visible on commits and PRs. Can be required as a merge gate via branch protection rules.

---

### 📡 Vercel Monitor Agent

**Trigger:** Push to `main` only

Goes deeper than the Deployment Check. Validates HTTP status, SSL certificate validity, and response body size (catches blank 200 pages). Deduplicates issues — won't create a second incident for the same commit SHA.

| | Deployment Check | Vercel Monitor |
|--|-----------------|----------------|
| Output | Commit status tick | GitHub Issue |
| Checks | HTTP status only | HTTP + SSL + body size |
| Purpose | Quick signal | Full incident report |

---

### 🛠️ Auto-Resolve Agent

**Trigger:** Issue opened with `bug`/`error`/`fix`/`crash`/`broken` in title, or labeled `bug`

Full flow:
1. Posts "investigating..." comment immediately
2. Collects source files + last 5 commit messages
3. Sends to **Claude API** (`claude-opus-4-20250514`) for diagnosis
4. Claude returns JSON: `{ diagnosis, fixable, confidence, affected_file, fix_summary }`
5. If `fixable: true` → creates `auto-fix/issue-N` branch + opens PR
6. If `fixable: false` → posts diagnosis + manual steps needed

Requires `ANTHROPIC_API_KEY` secret.

---

### 🔧 Error-Fix Agent

**Trigger:** Every push (concurrency-controlled — cancels older runs on same branch)

Four checks:
1. **TypeScript** — `tsc --noEmit`, counts errors, emits file-pinned annotations
2. **Build** — full `npm run build`, uploads log as artifact
3. **Python** — `python3 -m py_compile` on all `.py` files
4. **Secret scan** — checks only changed files for AWS keys, GitHub tokens, AI API keys

Auto-applies Ruff fixes if Python check fails and commits them. Uploads error report artifacts for 7 days.

---

## 🔑 Secrets Reference

### `GITHUB_TOKEN` permissions per agent

```yaml
# CI Agent
permissions:
  contents: read
  pull-requests: write

# Auto-Fix Agent
permissions:
  contents: write

# Security + Vercel Monitor
permissions:
  contents: read
  issues: write

# PR Validator
permissions:
  contents: read
  pull-requests: write

# Deployment Check
permissions:
  contents: read
  statuses: write

# Auto-Resolve
permissions:
  contents: write
  issues: write
  pull-requests: write

# Error-Fix
permissions:
  contents: write
  checks: write
```

---

## 📝 Conventional Commits Format

| Type | Use For | Example |
|------|---------|---------|
| `feat` | New feature | `feat(auth): add Google OAuth login` |
| `fix` | Bug fix | `fix(api): handle null Stripe response` |
| `docs` | Documentation | `docs(readme): add setup guide` |
| `style` | Formatting only | `style: fix indentation in utils.ts` |
| `refactor` | Code restructure | `refactor(db): extract query builder` |
| `test` | Tests | `test(auth): add JWT validation tests` |
| `chore` | Deps, tooling | `chore(deps): update Next.js to 14.2` |
| `perf` | Performance | `perf(images): lazy load below-fold` |
| `ci` | CI/CD changes | `ci: add deployment health check` |
| `build` | Build system | `build: switch webpack to vite` |
| `revert` | Revert commit | `revert: feat(auth): add OAuth login` |

---

## 🛠 Troubleshooting

| Problem | Fix |
|---------|-----|
| Workflow doesn't trigger | Check `on:` block. Verify file is in `.github/workflows/`. |
| Permission denied on git push | Settings → Actions → General → Read and write permissions |
| `npm ci` fails | Run `npm install` locally, commit `package-lock.json` |
| Auto-Resolve shows no AI diagnosis | Add `ANTHROPIC_API_KEY` to repo secrets |
| Deployment Check always fails | Add `VERCEL_PROJECT_URL` secret; increase `sleep` if deploy is slow |
| Vercel Monitor false positives | Increase `sleep 60` to `sleep 90` |
| Secret scan false positive | Tighten regex in the scan step or add path exclusions |
| Auto-Resolve triggers too broadly | Change `if:` to only check for the `bug` label |

**Enable debug logging** — add these as repo secrets:

| Secret | Value | Effect |
|--------|-------|--------|
| `ACTIONS_STEP_DEBUG` | `true` | Shows every shell command per step |
| `ACTIONS_RUNNER_DEBUG` | `true` | Runner-level diagnostics |

---

## 🏗 Architecture

### Permissions Matrix

| Agent | contents | pull-requests | issues | statuses | checks |
|-------|----------|--------------|--------|----------|--------|
| CI | read | write | — | — | — |
| Auto-Fix | write | — | — | — | — |
| Security | read | — | write | — | — |
| PR Validator | read | write | — | — | — |
| Deployment Check | read | — | — | write | — |
| Vercel Monitor | read | — | write | — | — |
| Auto-Resolve | write | write | write | — | — |
| Error-Fix | write | — | — | — | write |

### Stack

| Component | Technology |
|-----------|------------|
| Runner | `ubuntu-latest` |
| Node.js | v20 LTS |
| Python | 3.11 |
| JS Lint | ESLint |
| JS Format | Prettier |
| Python Lint/Format | Ruff |
| Vuln Scan | npm audit + pip-audit |
| AI Diagnosis | Anthropic Claude (`claude-opus-4-20250514`) |
| GitHub API | `actions/github-script@v7` |

---

## 📄 License

MIT © Rahul Singh

---

<div align="center">
Made with ❤️ by <strong>Rahul Singh</strong>
</div>
