# GTD+Todoist Plugin Design Plan
**Date:** 2026-03-02
**Status:** Implemented

---

## Overview

A standalone Claude Code plugin that implements the GTD (Getting Things Done) methodology
on top of Todoist. Skills guide users through capture, inbox processing, weekly review,
daily planning, and context-based task selection.

---

## Architecture

### Components

| Component | Location (installed) | Purpose |
|-----------|---------------------|---------|
| Skills (5) | `~/.claude/skills/gtd-*/` | Core GTD workflow implementations |
| Commands (5) | `~/.claude/commands/gtd-todoist:*.md` | Slash command entry points |
| Agent | `~/.claude/agents/todoist-gtd-assistant.md` | Multi-step Todoist operations |
| Bootstrap script | `scripts/setup-gtd-structure.sh` | Idempotent Todoist structure setup |
| Install script | `scripts/install.sh` | Deploy plugin files to `~/.claude/` |

### API Strategy

- **MCP (OAuth):** `~/.claude/mcp.json` → `https://ai.todoist.net/mcp` — provides `addTasks`, `findTasksByDate` in Claude Code
- **REST API v1:** `curl` calls from skills/agent — full CRUD on tasks, projects, labels
- **Auth:** `TODOIST_API_TOKEN` env var for REST; OAuth flow for MCP

Note: Todoist REST API v2 is deprecated (returns HTTP 410). All REST calls use `/api/v1/`.

---

## Todoist Structure (User's Account)

### Existing Structure (preserved)
```
Inbox                        ← 6CrcvJ4gf682FP8H (2 tasks)
Work/                        ← 6CrcvJ4h5frXcjvM (Active Projects)
  Misc. Projects, Human Recordings, Goals, Meetings, Confidence Project,
  Equipment, Administration, Reading, Ideas & Thoughts, Papers,
  Teaching, Grants, Conferences, Professional, Dual Stim Project, Social
Getting Things Done/         ← 6CrcvJ4hPxC5Mc2w (GTD hub)
  [Next Actions — created by bootstrap]
  [Waiting For — created by bootstrap]
  [Someday Maybe — created by bootstrap]
  [Reference — created by bootstrap]
  [Archive — created by bootstrap]
Life/                        ← 6CrcvJ4gffrcpV73 (Active Projects)
  Coding, Legal, BB, Jobs, Appointments, German, Stay in Touch,
  Birthdays, Finances, Hobbies, Body, Mind, Things, Concerts, Travel, Baking
```

### Labels (created by bootstrap)
Context: `@computer`, `@phone`, `@errands`, `@home`, `@work`, `@online`, `@agenda`
Effort: `#2min`, `#energy-low`, `#energy-high`
Existing: `Calendar` (preserved)

### Priority Convention
| GTD | Todoist API value | Meaning |
|-----|------------------|---------|
| P1 | 4 | Urgent + important (do today) |
| P2 | 3 | Important this week |
| P3 | 2 | Someday/lower priority |
| P4 | 1 | No priority (default) |

---

## Skill Specifications

### `gtd-capture`
- **Trigger:** "capture", "add task", "remember to", "I need to", "put in my todo"
- **Operations:** `POST /api/v1/tasks` → Inbox
- **Logic:** 2-minute rule check → optional enrichment (date/label/priority) → create task → confirm
- **MCP fallback:** Can use `addTasks` MCP tool when available

### `gtd-process-inbox`
- **Trigger:** "process inbox", "inbox zero", "clear inbox"
- **Operations:** `GET /api/v1/tasks?project_id=<inbox>` → for each: `POST /tasks/<id>` (move), `POST /tasks/<id>/close` (complete), `DELETE /tasks/<id>` (delete)
- **Logic:** Full GTD decision tree, one task at a time

### `gtd-weekly-review`
- **Trigger:** "weekly review", "GTD review", "review my week", "Friday review"
- **Operations:** Multiple fetches (inbox, next actions, waiting for, someday, projects), completions, moves
- **Logic:** 3 phases: Get Clear → Get Current → Get Creative

### `gtd-daily-plan`
- **Trigger:** "plan my day", "daily plan", "what should I work on", "morning planning"
- **Operations:** `GET /api/v1/tasks?filter=today|overdue`, context-filtered next actions
- **Logic:** Today's tasks + energy/context assessment → top 3 priorities

### `gtd-context-review`
- **Trigger:** "@computer", "@errands", "@phone", "@home", "@work", "@online", "context review"
- **Operations:** `GET /api/v1/tasks?project_id=<next_actions>&label=@context`
- **Logic:** Detect context → filter tasks → interactive selection/completion

---

## GTD Decision Tree (canonical)

```
Is it actionable?
├── NO
│   ├── Useful reference → Reference project
│   ├── Maybe later → Someday Maybe project
│   └── Junk → Delete
└── YES — what's the next physical action?
    ├── < 2 minutes → DO IT NOW → Complete task
    ├── Delegate it → Waiting For + @agenda label
    ├── Specific date → Next Actions with due date
    └── ASAP → Next Actions with @context label
              └── Multi-step? → Project exists with next action defined
```

---

## Installation

```bash
cd ~/Documents/Development/Skills/gtd-todoist
chmod +x scripts/install.sh scripts/setup-gtd-structure.sh
./scripts/install.sh

export TODOIST_API_TOKEN=<token>
./scripts/setup-gtd-structure.sh
```

---

## NanoClaw Integration (Phase 5 — future)

- Add `TODOIST_API_TOKEN` to `/home/nanoclaw/nanoclaw/.env` and `compose.yml`
- Add Todoist MCP (API key auth) to `/home/nanoclaw/nanoclaw/.mcp.json`
- Create `/home/nanoclaw/nanoclaw/groups/gtd/CLAUDE.md` for GTD agent context
- Optional: morning brief scheduler, inbox alert on new items
