---
name: gtd-weekly-review
description: >
  GTD weekly review — guided sweep of all lists, projects, and commitments to stay current.
  Use when: user says "weekly review", "GTD review", "review my week", "weekly planning",
  "end of week review", "Friday review".
user-invocable: true
---

# GTD Weekly Review

**Announce at start:** "Starting GTD Weekly Review. This usually takes 30–60 minutes. Let's get clear."

## What This Skill Does

Guides the user through the full GTD Weekly Review sequence: collect loose ends, process inbox, review all lists, update projects, and plan the coming week. Fetches live data from Todoist at each step.

## Weekly Review Sequence

### Phase 1: GET CLEAR — Collect Loose Ends

**1.1 Capture stragglers**
> "Before we look at your lists: is there anything on your mind, on paper, in your head, or in your environment that hasn't been captured yet?"

Allow free-form capture. Add any items to Inbox via the gtd-capture skill logic.

**1.2 Process Inbox**
Fetch inbox count:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?project_id=6CrcvJ4gf682FP8H" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

If inbox has items: "Your Inbox has **N items**. Would you like to process them now, or do it separately after this review?"

If user wants to process: invoke the gtd-process-inbox workflow inline.

### Phase 2: GET CURRENT — Review All Lists

**2.1 Review @next Actions**
Fetch all @next tasks:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%40next" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Group by context label (@work / @home / @errands / none). For each group, ask:
- Are any of these done? → complete them
- Are any no longer relevant? → delete or change to @someday
- Are any missing that should be here? → capture them

**2.2 Review @waitingon**
Fetch waiting-on tasks:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%40waitingon" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

For each item: "Any movement on this? Still waiting, or can it be closed/followed up?"
- Still waiting → leave, optionally update note
- Received → complete or add @next action
- Follow-up needed → add next action "Follow up with [person] re: [topic]"

**2.3 Review @someday**
Fetch someday tasks:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?label=%40someday" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

"Anything here that should become active now?"
- Yes → change label to @next, optionally add context label
- No longer relevant → delete
- Still someday → leave

**2.4 Review Active Projects**
Fetch all projects:
```bash
curl -s "https://api.todoist.com/api/v1/projects" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

For each active project (non-GTD meta): "Is there a clear @next action defined for this project?"
- If no @next tasks → add a next action
- If stalled → decide: is this still active or move everything to @someday?

### Phase 3: GET CREATIVE — Look Ahead

**3.1 Goals & Calendar Review**
> "Look at your calendar for the next week: any deadlines, appointments, or commitments?"
> "Are there any projects where you want to make progress this week?"

Help user define 1–3 weekly priorities. Optionally mark them P1 via API:
```bash
curl -s -X POST "https://api.todoist.com/api/v1/tasks/<task_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"priority": 4}'
```

**3.2 Someday Activation**
> "Anything you want to activate from @someday for this week or next?"

**3.3 Mind Sweep**
> "Anything else on your mind that we haven't captured? Any open loops, worries, ideas?"

Final capture round.

### Phase 4: Summary

Present a summary:
```
Weekly Review Complete ✓
─────────────────────────────────
Inbox:         X items processed → Zero
@next:         X tasks across Y contexts
@waitingon:    X items
@someday:      X items
Projects:      X active, X reviewed
Weekly focus:  [1-3 priorities user identified]
─────────────────────────────────
Next review:   [date + 7 days]
```

## Timing & Pacing

- Announce at each phase what you're doing
- Allow user to skip phases they don't need ("skip this section")
- Keep momentum — don't get bogged down in one area
- Total time goal: 30–60 minutes

## Key Project IDs

| Project | ID |
|---------|-----|
| Inbox | `6CrcvJ4gf682FP8H` |
| Reference | `6g6G3C5gPjh7mmmh` |
| Archive | `6g6G3C65hPRHCjJX` |
