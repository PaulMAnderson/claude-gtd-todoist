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

Fetches all tasks from the Todoist Inbox and guides the user through the GTD decision tree for each item, one at a time. Labels tasks or moves them to Reference — no separate GTD projects needed. Aims for Inbox Zero.

## GTD Decision Tree

For each inbox item, ask in order:

```
Is it actionable?
├── NO → Is it useful to keep?
│         ├── YES, reference → Move to Reference project (6g6G3C5gPjh7mmmh)
│         ├── YES, someday   → Add @someday label (stays in or move to best project)
│         └── NO             → Delete it
└── YES → What's the next physical action?
          ├── Takes < 2 min?      → DO IT NOW (tell user to do it, then complete task)
          ├── Delegated/waiting?  → Add @waitingon label + note who you're waiting on
          ├── Scheduled/deferred? → Add @next label + due date; move to appropriate project
          └── As-soon-as-can?     → Add @next label + context (@work/@home/@errands if relevant)
                                    If multi-step → move to appropriate project, define next action
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
1. **@next** — assign context: @errands / @home / @work (optional)
2. **@next** + move to a project — which project?
3. **@waitingon** — who are you waiting on?
4. **@someday** — park it for later
5. **Reference** — info to keep, no action needed
6. **2-min rule** — doing it now / done
7. **Delete** — it's irrelevant
---

### Step 3: Execute the Decision

After user input, call the appropriate API:

**Add @next label (stays in Inbox or move to project):**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"labels": ["@next", "@work"], "project_id": "<project_id_if_moving>"}'
```

**Add @waitingon label:**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"labels": ["@waitingon"]}'
```

**Add @someday label:**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"labels": ["@someday"]}'
```

**Move to Reference project:**
```bash
curl -s -X POST --url "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"project_id": "6g6G3C5gPjh7mmmh"}'
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

### Step 4: Pace & Momentum

After each item: "✓ Done. **N remaining.**"

Offer to pause: "Want to continue or take a break and come back later?"

### Step 5: Inbox Zero

When all items are processed:
> "Inbox Zero! You processed **N items**:
> - X → @next
> - X → @waitingon
> - X → @someday
> - X → Reference
> - X → [Project]
> - X deleted
> - X done (2-min rule)"

## Project IDs Reference

| Project | ID |
|---------|-----|
| Inbox | `6CrcvJ4gf682FP8H` |
| Reference | `6g6G3C5gPjh7mmmh` |
| Archive | `6g6G3C65hPRHCjJX` |
| Work | `6CrcvJ4h5frXcjvM` |

For other projects, fetch the project list and match by name.

## Notes

- Do NOT skip items. GTD requires processing every inbox item.
- If a task description is too vague (e.g., "thing"), ask the user what they meant before deciding.
- For tasks that are clearly multi-step (projects), note the next physical action and assign @next to it.
- Use TODOIST_API_TOKEN env var; if missing, prompt user to set it.
- When adding labels, always pass the full label array (Todoist replaces labels, not appends).
