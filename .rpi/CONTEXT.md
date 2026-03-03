# Session Context

_Last updated: 2026-03-03 — Task sweep + plugin skill update phase_

## Session Intent

Building and refining a GTD+Todoist Claude Code plugin (`claude-gtd-todoist`) for paul's personal productivity system. The full plan (phases 1–6) is implemented; we are now in a cleanup/polish pass: the Todoist structure was redesigned (label-based GTD instead of sub-projects), all 145 tasks have been labelled, and the plugin skills need updating to match the new structure. NanoClaw integration and GitHub push are already done.

## Files Modified

- `~/.claude/mcp.json`: Added Doist OAuth HTTP MCP server
- `~/.config/fish/config.fish`: Added TODOIST_API_TOKEN env var
- `~/Documents/Development/Skills/gtd-todoist/skills/gtd-capture/SKILL.md`: Smart skip-logic capture — infers context/date/priority from task text, only asks about genuinely unclear fields
- `~/Documents/Development/Skills/gtd-todoist/skills/gtd-process-inbox/SKILL.md`: GTD decision tree, inbox zero workflow
- `~/Documents/Development/Skills/gtd-todoist/skills/gtd-weekly-review/SKILL.md`: 3-phase weekly review
- `~/Documents/Development/Skills/gtd-todoist/skills/gtd-daily-plan/SKILL.md`: Daily planning with energy/context filtering
- `~/Documents/Development/Skills/gtd-todoist/skills/gtd-context-review/SKILL.md`: Context-filtered task view
- `~/Documents/Development/Skills/gtd-todoist/agents/todoist-gtd-assistant.md`: Full Todoist API v1 reference + GTD decision logic
- `~/Documents/Development/Skills/gtd-todoist/scripts/install.sh`: Installs skills/commands/agents to ~/.claude/
- `~/Documents/Development/Skills/gtd-todoist/scripts/setup-gtd-structure.sh`: Idempotent bootstrap (now partially superseded by new label approach)
- `/home/nanoclaw/nanoclaw/.env`: Added TODOIST_API_TOKEN
- `/home/nanoclaw/nanoclaw/compose.yml`: Added TODOIST_API_TOKEN env var
- `/home/nanoclaw/nanoclaw/src/container-runner.ts`: Added TODOIST_API_TOKEN to secrets allowlist
- `/home/nanoclaw/nanoclaw/groups/gtd/CLAUDE.md`: GTD agent context file (new)
- `/home/nanoclaw/nanoclaw/README.md`: Fork-specific changes section added
- `/home/nanoclaw/nanoclaw/CHANGELOG.md`: Created with all 10 fork changes documented
- `/home/nanoclaw/nanoclaw/docs/ROOTLESS_DOCKER_SETUP.md`: Created rootless Docker setup guide

## Decisions Made

- **Todoist API v1 only**: v2 returns HTTP 410 (deprecated); all calls use `/api/v1/`
- **Label-based GTD**: Tasks stay in their natural projects (Work, Home, etc.); GTD status is expressed via labels (@next, @waitingon, @someday) instead of moving tasks to dedicated GTD sub-projects. Next Actions / Waiting For / Someday Maybe sub-projects were deleted.
- **Simplified contexts**: Removed @phone and @computer (user doesn't think this way); kept only @work, @home, @errands
- **@agenda removed**: Replaced with @waitingon (more natural language for user)
- **GTD project = meta-tasks only**: Weekly Review, Process Inbox, Daily Planning recurring tasks live here
- **Reference and Archive kept as sub-projects**: Under Getting Things Done — for non-actionable reference material and completed projects
- **Recurring tasks left without @next/@someday**: They manage themselves via due dates
- **Reading backlog → all @someday**: User said they'll sort through them; @someday is the right default for a large backlog
- **Dual Stim Project: first task @next, rest @someday**: Sequential project — only the first actionable step is @next
- **Cannot reparent root-level projects via REST API**: Workaround is delete + recreate with correct parent_id at creation time
- **Cascade deletion risk**: Deleting a parent project deletes all children and their tasks — always snapshot first
- **Filters must be created manually in Todoist UI**: API v1 has no filter endpoint

## Current State

**Todoist structure**: Fully restructured and colour-coded. Projects:
- Inbox (grey), Getting Things Done/Reference+Archive (charcoal), Work (blue, many sub-projects), BB (yellow), Administration/Appointments+Jobs+Finances+Legal (teal), Home (orange), Body (salmon), Mind/Piano+Mathematics+Philosophy+Meditation+German (grape), Hobbies/Tech Projects+Gen Art+Baking+Coding+Things (green), Social/Birthdays (magenta), Events & Travel/Concerts (sky_blue)

**Labels**: @next, @waitingon, @someday (status) + @work, @home, @errands (context) + #2min, #energy-low, #energy-high + Calendar. @phone and @computer have been deleted.

**Task sweep**: Complete. 145 tasks → 45 @next, 81 @someday, 0 @waitingon, 19 recurring (no label needed).

**Plugin**: Installed at `~/.claude/` from `~/Documents/Development/Skills/gtd-todoist/`. GitHub repo: `PaulMAnderson/claude-gtd-todoist`. Skills/commands/agent are installed but **still reference the old structure** (@phone, @computer, Next Actions project IDs, etc.) — this is what Task #10 is fixing.

**NanoClaw**: Integrated (env var, container allowlist, gtd group). All 11 commits pushed to `PaulMAnderson/nanoclaw`.

**Task list**:
- #8 ✅ Restructure Todoist
- #9 ✅ Big sweep (all tasks labelled)
- #10 🔄 in_progress — Update plugin skills to reflect new structure
- #11 ✅ Execute restructure

## Next Steps

1. Update `skills/gtd-capture/SKILL.md` — remove @phone/@computer from inference table; only use @work/@home/@errands; remove references to Next Actions project; use @next label instead
2. Update `skills/gtd-process-inbox/SKILL.md` — replace GTD decision tree project moves with label assignments (@next/@waitingon/@someday); remove Next Actions / Waiting For / Someday Maybe project ID references; add correct project IDs (Reference: 6g6G3C5gPjh7mmmh, Archive: 6g6G3C65hPRHCjJX)
3. Update `skills/gtd-weekly-review/SKILL.md` — replace project-based queries with label-based queries; update project IDs
4. Update `skills/gtd-daily-plan/SKILL.md` — query by @next label (not Next Actions project); remove @phone/@computer from context filter
5. Update `skills/gtd-context-review/SKILL.md` — only offer @work/@home/@errands contexts
6. Update `agents/todoist-gtd-assistant.md` — update all project IDs, label set, remove @phone/@computer, replace project moves with label assignments, reflect new structure
7. Run `bash scripts/install.sh` to reinstall updated skills
8. Commit and push plugin repo changes
