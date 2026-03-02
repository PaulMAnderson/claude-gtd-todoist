---
name: gtd-process-inbox
description: >
  GTD inbox processing — work through every item in Todoist Inbox using the GTD decision tree,
  reaching Inbox Zero. Use when: user says "process my inbox", "inbox zero", "clear my inbox",
  "what's in my inbox", "go through my inbox".
user-invocable: true
---

# GTD Process Inbox

**Announce at start:** "Starting GTD Inbox Processing. Let's work through each item and get to Inbox Zero."

## What This Skill Does

Fetches all tasks from the Todoist Inbox and guides the user through the GTD decision tree for each item, one at a time. Moves tasks to the right place (Next Actions, Waiting For, Someday Maybe, Reference, a specific project, or trash). Aims for Inbox Zero.

## GTD Decision Tree

For each inbox item, ask in order:

```
Is it actionable?
├── NO → Is it useful to keep?
│         ├── YES, reference → Move to Reference project
│         ├── YES, someday   → Move to Someday Maybe project
│         └── NO             → Delete it
└── YES → What's the next physical action?
          ├── Takes < 2 min?      → DO IT NOW (tell user to do it, then delete task)
          ├── Delegated/waiting?  → Move to Waiting For, add @agenda-[person] label
          ├── Scheduled/deferred? → Move to Next Actions with due date
          └── As-soon-as-can?     → Move to Next Actions with @context label
                                    If multi-step → create/assign to Active Project
```

## Processing Flow

### Step 1: Fetch Inbox

```bash
curl -s --url "https://api.todoist.com/api/v1/tasks?project_id=6CrcvJ4gf682FP8H" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Count items and announce: "You have **N items** in your Inbox. Let's process them."

If inbox is empty: "Your Inbox is already empty — Inbox Zero achieved!"

### Step 2: Present Each Item

Show the item and ask the decision tree questions. Be concise — this should feel like a rhythm, not a quiz. Example format:

---
**Item 1/N:** "Buy groceries"

What should we do with this?
1. **Next Action** — assign context: @errands / @home / @computer / @phone / @work / @online
2. **Project task** — assign to which project?
3. **Waiting For** — who are you waiting on?
4. **Someday Maybe** — park it for later
5. **Reference** — info to keep, no action
6. **2-min rule** — doing it now / done
7. **Delete** — it's irrelevant
---

### Step 3: Execute the Decision

After user input, call the appropriate API:

**Move to Next Actions project:**
```bash
# Get Next Actions project ID first (child of 6CrcvJ4hPxC5Mc2w named "Next Actions")
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"project_id": "<next_actions_id>", "labels": ["@computer"]}'
```

**Move to Waiting For:**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"project_id": "<waiting_for_id>", "labels": ["@agenda"]}'
```

**Move to Someday Maybe:**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"project_id": "<someday_id>"}'
```

**Delete task:**
```bash
curl -s -X DELETE --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

**Complete (2-min rule done):**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>/close" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

### Step 4: Fetch GTD Project IDs

Before processing, resolve the child project IDs:

```bash
curl -s --url "https://api.todoist.com/api/v1/projects" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" | \
python3 -c "
import json,sys
projects = json.load(sys.stdin)
p = projects.get('results', projects) if isinstance(projects, dict) else projects
gtd_parent = '6CrcvJ4hPxC5Mc2w'
gtd = {x['name']: x['id'] for x in p if x.get('parent_id') == gtd_parent}
print(json.dumps(gtd))
"
```

### Step 5: Pace & Momentum

After each item: "✓ Done. **N remaining.**"

Offer to pause: "Want to continue or take a break and come back later?"

### Step 6: Inbox Zero

When all items are processed:
> "Inbox Zero! You processed **N items**:
> - X → Next Actions
> - X → Waiting For
> - X → Someday Maybe
> - X → Reference
> - X → [Project]
> - X deleted
> - X done (2-min rule)"

## Notes

- Do NOT skip items. GTD requires processing every inbox item.
- If a task description is too vague (e.g., "thing"), ask the user what they meant before deciding.
- For tasks that are clearly multi-step (projects), note the next physical action and assign it.
- Use TODOIST_API_TOKEN env var; if missing, prompt user to set it.
