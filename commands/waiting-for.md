---
description: GTD waiting-for review — show all delegated items you're waiting on, with follow-up prompts
---

Fetch and review the Waiting For list from Todoist.

Use your Skill tool to invoke the `gtd-context-review` skill, but focus specifically on the Waiting For project rather than a context label.

Specifically:
1. Fetch tasks from the Waiting For project (child of Getting Things Done, parent_id=6CrcvJ4hPxC5Mc2w, name="Waiting For")
2. Show each item with who you're waiting on and when it was added
3. For each item ask: "Still waiting? Need to follow up? Or can this be closed?"
4. If follow-up needed: add a new next action "Follow up with [person] re: [topic]" to Next Actions with @computer or @phone label as appropriate
5. If received: complete the waiting-for task

Use Bash with the Todoist API v1 and TODOIST_API_TOKEN env var.
