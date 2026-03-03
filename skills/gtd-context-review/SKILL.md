---
name: gtd-context-review
description: >
  GTD context review — show all next actions for a specific context/situation.
  Use when: user says "@errands", "@home", "@work", "what can I do at home",
  "what can I do at work", "running errands", "context review".
user-invocable: true
---

# GTD Context Review

**Announce at start:** "Pulling up your next actions for this context."

## What This Skill Does

Fetches and presents @next tasks filtered by context label, sorted by priority. Helps the user execute tasks in their current situation without having to think about what's appropriate.

## Context Detection

First, detect the context from the user's message:

| User says | Context label |
|-----------|--------------|
| "@errands", "running errands", "out and about", "on the way" | @errands |
| "@home", "at home", "around the house", "in the flat" | @home |
| "@work", "at work", "at the office", "at the lab" | @work |
| "all", "everything", "all contexts" | (no filter — show all @next) |

If unclear, ask: "Which context are you in? (@work / @home / @errands)"

## Fetch Tasks

```bash
# Fetch all @next tasks, then filter by context client-side
curl -s "https://api.todoist.com/api/v1/tasks?label=%40next" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Filter results to those also having the detected context label (e.g. `@work`).
If no context filter, show all @next tasks grouped by project.

## Display Format

Group by priority, then show ordered list:

```
@work Next Actions (N tasks)
──────────────────────────────────
P1 (Urgent):
  □ [task] — [project]
  □ [task] — [project]

P2 (This week):
  □ [task] — [project]
  □ [task] — [project]

P3/P4:
  □ [task] — [project]
──────────────────────────────────
Also available: #2min tasks (N)
```

If `#energy-low` label filter is useful, also show: "Low energy options: [N tasks with #energy-low]"

## Interactive Mode

After showing the list, offer:
> "Which one would you like to work on? Or I can:
> 1. Mark something as done
> 2. Show #2min tasks only
> 3. Show a different context
> 4. Add a new next action here"

**Mark as done:**
```bash
curl -s -X POST "https://api.todoist.com/api/v1/tasks/<task_id>/close" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

**Add next action with context:**
```bash
curl -s -X POST "https://api.todoist.com/api/v1/tasks" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{\"content\": \"<task>\", \"project_id\": \"6CrcvJ4gf682FP8H\", \"labels\": [\"@next\", \"$CONTEXT_LABEL\"]}"
```

(Creates in Inbox with @next + context; process into correct project later if needed.)

## Special Cases

**"#2min tasks"** — show tasks labeled `#2min` regardless of context:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%232min" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

**"Low energy"** — show tasks labeled `#energy-low`:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%23energy-low" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

**"Waiting on"** — show @waitingon tasks to check for follow-ups:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%40waitingon" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```
