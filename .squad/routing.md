# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Azure architecture and cross-module design | Tony Stark | Module interfaces, consistency, technical decisions, issue triage |
| Azure security and hardening | Shuri | Secure defaults, identity and RBAC, network boundaries, security controls |
| Bicep module implementation | Bruce Banner | Resource modules, parameters, outputs, API versions |
| Testing and module quality | Peter Parker | Bicep validation, module tests, deployment examples, regressions |
| CI/CD and registry operations | Nick Fury | GitHub Actions, publishing, versioning, documentation workflows |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage the issue and assign the best-fit member label | Tony Stark |
| `squad:tony-stark` | Pick up architecture and cross-module issues | Tony Stark |
| `squad:shuri` | Pick up security and hardening issues | Shuri |
| `squad:bruce-banner` | Pick up Bicep module implementation issues | Bruce Banner |
| `squad:peter-parker` | Pick up testing and quality issues | Peter Parker |
| `squad:nick-fury` | Pick up CI/CD and registry issues | Nick Fury |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, **Tony Stark** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, the corresponding member picks up the issue.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

## Rules

1. Every work item has one accountable owner. Split work only when outcomes are independently deliverable and have distinct owners.
2. Spawn contributors or reviewers only for a concrete, bounded need; do not launch anticipatory work.
3. Scribe runs only when accepted durable decisions require merging and never blocks active work.
4. Quick factual questions are answered directly; otherwise route to the primary domain owner.
5. A request addressed to the team does not imply fan-out. The accountable owner may request bounded input.
6. Issue-labeled work routes to the named member; Tony Stark handles base `squad` triage.
