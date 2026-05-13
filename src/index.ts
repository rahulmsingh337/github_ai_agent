/**
 * GitHub AI Agents - Entry Point
 * Built by Rahul Singh
 *
 * This repository contains 8 GitHub Actions agents.
 * See .github/workflows/ for all agent definitions.
 * See README.md for full documentation.
 */

export const agents = [
  { id: 1, name: "CI Agent",           trigger: "push + PR" },
  { id: 2, name: "Auto-Fix Agent",     trigger: "manual" },
  { id: 3, name: "Security Agent",     trigger: "weekly + dep changes" },
  { id: 4, name: "PR Validator",       trigger: "pull_request" },
  { id: 5, name: "Deployment Check",   trigger: "push to main" },
  { id: 6, name: "Vercel Monitor",     trigger: "push to main" },
  { id: 7, name: "Auto-Resolve Agent", trigger: "issue opened" },
  { id: 8, name: "Error-Fix Agent",    trigger: "push" },
] as const;

export type AgentName = typeof agents[number]["name"];
