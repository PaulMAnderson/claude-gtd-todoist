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

Captures one or more items into the Todoist Inbox. Before asking any questions, infer as much as possible from the user's message — only ask about things that are genuinely unclear.

## Step 1: Extract the Item(s)

Parse the user's message to identify what needs capturing. If multiple items are mentioned, capture each separately. Use the user's exact language as the task name — do not rephrase or summarize.

## Step 2: Infer What You Can (Skip Logic)

Before asking anything, scan the task description and auto-assign as many fields as possible. Only ask about fields you cannot infer.

### Context label — infer from verbs and nouns

| If the task contains... | Auto-assign |
|------------------------|-------------|
| "call", "ring", "phone", "text", "WhatsApp" | `@phone` |
| "buy", "pick up", "get", "shop", "errand", "post office", "pharmacy" | `@errands` |
| "email", "google", "look up", "research", "book" (online), "order" (online) | `@computer` |
| "at work", "in the office", "at the lab" | `@work` |
| "at home", "around the house", "in the flat" | `@home` |
| "website", "online", "browser", "download", "upload" | `@online` |

If context is ambiguous or the task could apply anywhere → leave unlabelled (Inbox with no label is fine).

### 2-minute rule — infer from complexity

- If the task description is clearly a single, simple action (e.g. "reply to Sarah's email", "call dentist") → apply 2-min check (see Step 3)
- If the task is clearly multi-step or substantial (e.g. "plan the conference", "write the report") → skip the 2-min check entirely, just capture it

### Due date — infer from time words

| If the task contains... | Auto-assign |
|------------------------|-------------|
| "today", "tonight", "this morning/afternoon" | due: today |
| "tomorrow" | due: tomorrow |
| "this week", "by Friday" | due: this week |
| "on [day/date]" | due: that day |
| No time reference | leave undated |

### Priority — infer from urgency words

| Signal | Priority |
|--------|----------|
| "urgent", "ASAP", "critical", "must", "deadline today" | P1 (API: 4) |
| "this week", "important", "need to" | P2 (API: 3) |
| "someday", "eventually", "when I get a chance" | P3 (API: 2) |
| No urgency signal | P4 (API: 1) — default |

## Step 3: 2-Minute Rule (only if task is simple and rule not skipped)

Ask: **"That sounds quick — could you do it in under 2 minutes right now?"**

- Yes → suggest doing it now; if they do it, no need to capture
- No / busy → proceed to capture
- Skip entirely if the task is clearly not a 2-minute job

## Step 4: Ask Only What Remains Unclear

After inference, only prompt the user for fields that are still unknown — and only if they materially affect where/when the task appears. Do NOT ask about all fields by default.

Good reasons to ask:
- Context is genuinely ambiguous and it would affect when they see the task
- They mentioned a project name that might exist in Todoist

Do NOT ask about:
- Fields you've already inferred with confidence
- Priority if there's no urgency signal (P4 default is fine)
- Due date if there's no time reference (undated is fine)

If everything is clear from the message: **skip straight to Step 5 with no questions asked.**

## Step 5: Add to Todoist

```bash
curl -s -X POST \
  --url "https://api.todoist.com/api/v1/tasks" \
  --header "Authorization: Bearer $TODOIST_API_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "content": "<task content>",
    "project_id": "6CrcvJ4gf682FP8H",
    "priority": <1-4>,
    "labels": ["<label if inferred>"],
    "due_string": "<due string if inferred>"
  }'
```

Omit `labels` if none inferred. Omit `due_string` if undated.

Priority mapping: P1=4, P2=3, P3=2, P4=1 (Todoist reverses the scale).

## Step 6: Confirm

One line, no fanfare:
> "Captured: **[task name]**" + context label if set + due date if set

For multiple items, list each on its own line.

## Examples

**Everything inferred — zero questions:**
> "Remember to call the dentist"
> → label: @phone (inferred from "call"), 2-min: skip (dentist calls take time)
> → "Captured: **Call the dentist** @phone"

**Date and context inferred:**
> "I need to pick up milk on the way home tomorrow"
> → label: @errands, due: tomorrow
> → "Captured: **Pick up milk** @errands · tomorrow"

**2-min rule triggered:**
> "I need to reply to that Slack message from Jon"
> → label: @computer, clearly simple
> → "That sounds quick — could you reply now in under 2 minutes?"

**Nothing to infer, no questions either — just capture:**
> "Think about what to do with the garage"
> → vague, no context, not actionable yet — goes to Inbox unlabelled
> → "Captured: **Think about what to do with the garage** → Inbox"

**Multi-step, skip 2-min:**
> "Plan the department away day"
> → clearly multi-step, skip 2-min rule, label: @work (inferred)
> → "Captured: **Plan the department away day** @work"

## Error Handling

If `TODOIST_API_TOKEN` is not set:
> "I need your Todoist API token. Please set: `export TODOIST_API_TOKEN=<your-token>`"

If the API returns an error, show it and suggest the user check their token.
