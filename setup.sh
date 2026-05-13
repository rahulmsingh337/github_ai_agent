#!/bin/bash
# =============================================================
#  GitHub AI Agents — One-Shot Repo Setup Script
#  Author: Rahul Singh
#  Repo:   rahulmsingh337/github_ai_agent
# =============================================================
# USAGE:
#   1. Generate a new GitHub PAT with scopes: repo + workflow
#   2. Run: GITHUB_TOKEN=ghp_xxxx bash setup.sh
# =============================================================

set -e

TOKEN="${GITHUB_TOKEN}"
OWNER="rahulmsingh337"
REPO="github_ai_agent"
API="https://api.github.com"
HEADERS=(-H "Authorization: token $TOKEN" -H "Content-Type: application/json" -H "Accept: application/vnd.github.v3+json")

if [ -z "$TOKEN" ]; then
  echo "❌ ERROR: Set GITHUB_TOKEN env var before running."
  echo "   Usage: GITHUB_TOKEN=ghp_xxx bash setup.sh"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🤖 GitHub AI Agents — Repo Setup"
echo "  Owner: $OWNER  |  Repo: $REPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Create the repository ──────────────────────────────────
echo ""
echo "▶ Step 1/4: Creating repository..."
REPO_RESPONSE=$(curl -s -w "\n%{http_code}" "${HEADERS[@]}" \
  -d "{
    \"name\": \"$REPO\",
    \"description\": \"8 GitHub Actions AI agents for CI/CD, security, deployment monitoring and auto-resolution. Built by Rahul Singh.\",
    \"private\": false,
    \"auto_init\": true,
    \"has_issues\": true,
    \"has_projects\": false,
    \"has_wiki\": false
  }" \
  "$API/user/repos")

HTTP_CODE=$(echo "$REPO_RESPONSE" | tail -1)
BODY=$(echo "$REPO_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "201" ]; then
  echo "   ✅ Repository created: https://github.com/$OWNER/$REPO"
elif [ "$HTTP_CODE" = "422" ]; then
  echo "   ℹ️  Repository already exists — continuing with file push"
else
  echo "   ❌ Failed to create repo (HTTP $HTTP_CODE)"
  echo "   $BODY"
  exit 1
fi

sleep 2

# ── Helper: get file SHA if it exists ────────────────────────
get_sha() {
  local path="$1"
  curl -s "${HEADERS[@]}" "$API/repos/$OWNER/$REPO/contents/$path" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('sha',''))" 2>/dev/null || echo ""
}

# ── Helper: push a file ───────────────────────────────────────
push_file() {
  local path="$1"
  local content_b64="$2"
  local message="$3"
  local sha="$4"

  if [ -n "$sha" ]; then
    PAYLOAD="{\"message\":\"$message\",\"content\":\"$content_b64\",\"sha\":\"$sha\"}"
  else
    PAYLOAD="{\"message\":\"$message\",\"content\":\"$content_b64\"}"
  fi

  CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HEADERS[@]}" \
    -X PUT -d "$PAYLOAD" \
    "$API/repos/$OWNER/$REPO/contents/$path")

  if [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then
    echo "   ✅ $path"
  else
    echo "   ❌ $path (HTTP $CODE)"
  fi
}

# ── 2. Push README ───────────────────────────────────────────
echo ""
echo "▶ Step 2/4: Pushing README..."
README_CONTENT=$(cat << 'READMEEOF'
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

> `GITHUB_TOKEN` is auto-provided by GitHub — no setup needed.

---

## License

MIT © Rahul Singh
READMEEOF
)
README_B64=$(echo "$README_CONTENT" | base64 -w 0)
README_SHA=$(get_sha "README.md")
push_file "README.md" "$README_B64" "docs: add README" "$README_SHA"

# ── 3. Push all 8 workflow files ─────────────────────────────
echo ""
echo "▶ Step 3/4: Pushing 8 workflow files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

push_workflow() {
  local filename="$1"
  local filepath="$SCRIPT_DIR/.github/workflows/$filename"
  if [ ! -f "$filepath" ]; then
    echo "   ⚠️  Missing: $filepath — skipping"
    return
  fi
  local b64=$(base64 -w 0 < "$filepath")
  local sha=$(get_sha ".github/workflows/$filename")
  push_file ".github/workflows/$filename" "$b64" "ci: add $filename" "$sha"
}

push_workflow "ci.yml"
push_workflow "auto-fix.yml"
push_workflow "security.yml"
push_workflow "pr-validator.yml"
push_workflow "deployment-check.yml"
push_workflow "vercel-monitor.yml"
push_workflow "auto-resolve.yml"
push_workflow "error-fix.yml"

# ── 4. Enable workflow permissions ───────────────────────────
echo ""
echo "▶ Step 4/4: Enabling workflow write permissions..."
CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HEADERS[@]}" \
  -X PUT \
  -d '{"default_workflow_permissions":"write","can_approve_pull_request_reviews":true}' \
  "$API/repos/$OWNER/$REPO/actions/permissions/workflow")
if [ "$CODE" = "204" ]; then
  echo "   ✅ Workflow permissions set to read+write"
else
  echo "   ⚠️  Could not set workflow permissions automatically (HTTP $CODE)"
  echo "   → Do it manually: Settings → Actions → General → Workflow permissions"
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ All done!"
echo "  🔗 https://github.com/$OWNER/$REPO"
echo ""
echo "  Next steps:"
echo "  1. Add secrets: Settings → Secrets → Actions"
echo "     - VERCEL_PROJECT_URL (for agents 5 & 6)"
echo "     - ANTHROPIC_API_KEY  (for agent 7)"
echo "  2. Push any commit to trigger the agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
