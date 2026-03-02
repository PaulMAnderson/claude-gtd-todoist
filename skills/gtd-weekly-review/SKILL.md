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

**2.1 Review Next Actions**
Fetch all Next Actions tasks grouped by context label:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?project_id=<next_actions_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

Show grouped list. For each context, ask:
- Are any of these done? → complete them
- Are any no longer relevant? → delete or move to Someday
- Are any missing that should be here? → capture them

**2.2 Review Waiting For**
Fetch Waiting For tasks:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?project_id=<waiting_for_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

For each item: "Any movement on this? Still waiting, or can it be closed/followed up?"
- Still waiting → leave, optionally update note
- Received → complete or move to Next Actions
- Follow-up needed → add next action "Follow up with [person] re: [topic]"

**2.3 Review Someday Maybe**
Fetch Someday Maybe tasks:
```bash
curl -s "https://api.todoist.com/api/v1/tasks?project_id=<someday_id>" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

"Anything here that should become active now?"
- Yes → move to Next Actions or a project
- No longer relevant → delete
- Still someday → leave

**2.4 Review Active Projects**
Fetch all top-level projects (Work, Life, Getting Things Done):
```bash
curl -s "https://api.todoist.com/api/v1/projects" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN"
```

For each active project (non-GTD): "Is there a clear next action defined for this project?"
- If no tasks → add a next action
- If stalled → decide: is this still active or move to Someday?

### Phase 3: GET CREATIVE — Look Ahead

**3.1 Goals & Calendar Review**
> "Look at your calendar for the next week: any deadlines, appointments, or commitments?"
> "Are there any projects where you want to make progress this week?"

Help user define 1–3 weekly priorities. Optionally add them as P1 tasks in Next Actions.

**3.2 Someday Activation**
> "Anything you want to activate from Someday Maybe for this week or next?"

**3.3 Mind Sweep**
> "Anything else on your mind that we haven't captured? Any open loops, worries, ideas?"

Final capture round.

### Phase 4: Summary

Present a summary:
```
Weekly Review Complete ✓
─────────────────────────────────
Inbox:         X items processed → Zero
Next Actions:  X items across Y contexts
Waiting For:   X items
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

## API Note

Resolve GTD child project IDs before the review:
```bash
curl -s "https://api.todoist.com/api/v1/projects" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" | \
python3 -c "
import json,sys
p = json.load(sys.stdin)
projects = p.get('results', p) if isinstance(p, dict) else p
gtd = {x['name']: x['id'] for x in projects if x.get('parent_id') == '6CrcvJ4hPxC5Mc2w'}
print(json.dumps(gtd, indent=2))
"
```
