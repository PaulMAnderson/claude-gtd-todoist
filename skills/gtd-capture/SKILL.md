---
name: gtd-capture
description: >
  GTD capture workflow — quickly capture tasks, ideas, or commitments into Todoist Inbox.
  Applies the 2-minute rule: do it now if it takes under 2 minutes, otherwise capture it.
  Use when: user says "I need to capture", "add a task", "remember to", "I need to", "can you add", "put in my todo list".
user-invocable: true
---

# GTD Capture

**Announce at start:** "Using GTD Capture to log this in your Todoist Inbox."

## What This Skill Does

Captures one or more items into the Todoist Inbox using the GTD capture discipline. Applies the 2-minute rule and optionally assigns a context label or due date.

## Capture Protocol

### Step 1: Extract the Item(s)

Parse the user's message to identify what needs capturing. If multiple items are mentioned, capture each separately. Use the user's exact language as the task name — do not rephrase or summarize.

### Step 2: Apply the 2-Minute Rule

Before capturing, ask: **"Could this be done in under 2 minutes?"**

- If yes AND user is at their computer: suggest doing it now instead of capturing
- If no, or user is busy: proceed to capture
- If unclear: capture it (err on the side of capture)

### Step 3: Enrich the Task (Optional)

Ask only if not obvious from context:
- **Due date?** (today, tomorrow, specific date, or leave undated)
- **Context label?** (@computer, @phone, @errands, @home, @work, @online)
- **Priority?** (P1=urgent today, P2=this week, P3=someday — default P4 if unspecified)
- **Project?** If the task clearly belongs to an active project, ask if they want it there instead of Inbox

For quick one-off captures, skip asking and just put it in Inbox with no label/date.

### Step 4: Add to Todoist

Use Bash to call the Todoist API v1:

```bash
curl -s --request POST \
  --url "https://api.todoist.com/api/v1/tasks" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "content": "<task content>",
    "project_id": "6CrcvJ4gf682FP8H",
    "priority": <1-4>,
    "labels": ["<label>"],
    "due_string": "<due string or omit>"
  }'
```

Project IDs:
- Inbox: `6CrcvJ4gf682FP8H`
- Next Actions: look up from `GET /api/v1/projects` filtered by parent `6CrcvJ4hPxC5Mc2w` and name "Next Actions"

Priority mapping: P1=4, P2=3, P3=2, P4=1 (Todoist reverses the scale).

### Step 5: Confirm

Confirm what was captured:
> "Captured: **[task name]** → Inbox [+ any labels/date]"

For multiple items, list all captures.

## Examples

**Quick capture:**
> User: "Remember to call the dentist"
> → Capture "Call the dentist" to Inbox, P4, no label. Done.

**Contextual capture:**
> User: "I need to buy groceries on the way home"
> → Capture "Buy groceries" to Inbox, label @errands, no due date.

**With 2-min rule:**
> User: "I need to reply to that Slack message"
> → "That sounds like it might take under 2 minutes — do you want to do it now, or capture it for later?"

## Error Handling

If `TODOIST_API_TOKEN` is not set:
> "I need your Todoist API token to capture tasks. Please set: `export TODOIST_API_TOKEN=<your-token>`"

If API returns an error, show the error and suggest the user try again or check their token.
