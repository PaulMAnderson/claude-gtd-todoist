---
name: gtd-daily-plan
description: >
  GTD daily planning — review what's on for today, pick next actions by energy/context,
  and set a clear focus for the day. Use when: user says "plan my day", "what should I work on",
  "morning planning", "what's on today", "daily standup", "what are my priorities today".
user-invocable: true
---

# GTD Daily Plan

**Announce at start:** "Let's plan your day using GTD. I'll check your tasks and help you set a clear focus."

## What This Skill Does

Checks Todoist for today's due tasks and @next actions, then helps the user pick their top 3 priorities and plan their energy. Takes about 5–10 minutes.

## Daily Planning Flow

### Step 1: Check Today's Tasks

Fetch tasks due today or overdue:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?filter=today%20%7C%20overdue" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Group by priority and show:
```
TODAY & OVERDUE (N tasks):
  P1 [urgent]: ...
  P2 [important]: ...
  P3/P4: ...
```

If none: "Nothing due today! Let's look at your next actions."

### Step 2: Ask About Context & Energy

> "Where are you working today — mainly @work, @home, or out (@errands)?"
> "Energy level? High (deep work), medium (normal tasks), or low (light/admin tasks)?"

### Step 3: Fetch @next Actions by Context

```bash
# Fetch @next tasks for the user's context (e.g. @work)
curl -s "https://api.todoist.com/api/v1/tasks?label=%40next" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Filter client-side by the chosen context label (@work / @home / @errands).

Filter based on energy:
- **High energy** → P1/P2 tasks first
- **Low energy** → tasks with label `#energy-low` or `#2min`
- **Medium** → standard priority order

Show top 5–10 candidates.

### Step 4: Check Calendar Conflicts

> "Do you have any meetings or fixed commitments today? (I don't have calendar access — just tell me.)"

Block out those times and estimate available focus time.

### Step 5: Set the Day's Focus

Help user pick **top 3 priorities** for the day:
> "Based on what's due and your energy, here are my suggested top 3:
> 1. [task]
> 2. [task]
> 3. [task]
> Agree? Or would you like to swap any?"

Optionally set P1 on chosen tasks via API:
```bash
curl -s -X POST "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"priority": 4}'
```

### Step 6: Check Waiting On

Fetch items you're waiting on:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%40waitingon" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

"Is there anything you need to follow up on today from your Waiting On list?"

### Step 7: Daily Plan Summary

```
Your Day — [date]
──────────────────────────────────
Focus:
  1. [top priority]
  2. [second priority]
  3. [third priority]

Also due today: [list]
Waiting on follow-up: [if any]
Energy: [high/medium/low]
Context: [@work/@home/@errands]
──────────────────────────────────
Go! ✓
```

## Tips

- If energy is low, suggest batching `#2min` tasks or light @errands work
- Remind user to time-block focus tasks if they mention meetings
- If user has >10 due tasks, ask which to defer to tomorrow
- Filter endpoint may need URL encoding: `today | overdue` → `today%20%7C%20overdue`
