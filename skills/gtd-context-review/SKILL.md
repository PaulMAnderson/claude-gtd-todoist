---
name: gtd-context-review
description: >
  GTD context review — show all next actions for a specific context/situation.
  Use when: user says "@computer", "@errands", "@phone", "@home", "@work", "@online",
  "what can I do at home", "what can I do on my phone", "context review", "running errands".
user-invocable: true
---

# GTD Context Review

**Announce at start:** "Pulling up your next actions for this context."

## What This Skill Does

Fetches and presents next actions filtered by context label (or all contexts), sorted by priority. Helps the user execute tasks in their current situation without having to think about what's appropriate.

## Context Detection

First, detect the context from the user's message:

| User says | Context label |
|-----------|--------------|
| "@computer", "at my computer", "on computer" | @computer |
| "@phone", "on my phone", "phone calls" | @phone |
| "@errands", "running errands", "out and about" | @errands |
| "@home", "at home", "around the house" | @home |
| "@work", "at work", "at the office" | @work |
| "@online", "online", "browser tasks" | @online |
| "all", "everything", "all contexts" | (no filter) |

If unclear, ask: "Which context are you in? (@computer / @phone / @errands / @home / @work / @online)"

## Fetch Tasks

```bash
# Fetch next actions with context label
LABEL="@computer"  # or whichever detected
curl -s "https://api.todoist.com/api/v1/tasks?project_id=<next_actions_id>&label=${LABEL}" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

To get tasks across ALL projects with a label:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=${LABEL}" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

## Display Format

Group by priority, then show ordered list:

```
@computer Next Actions (N tasks)
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
  --data "{\"content\": \"<task>\", \"project_id\": \"<next_actions_id>\", \"labels\": [\"$LABEL\"]}"
```

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

## Resolve Project ID

```bash
NEXT_ACTIONS_ID=$(curl -s "https://api.todoist.com/api/v1/projects" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" | \
python3 -c "
import json,sys
p = json.load(sys.stdin)
projects = p.get('results', p) if isinstance(p, dict) else p
print(next((x['id'] for x in projects if x['name'] == 'Next Actions' and x.get('parent_id') == '6CrcvJ4hPxC5Mc2w'), 'NOT_FOUND'))
")
```
