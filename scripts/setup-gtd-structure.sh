#!/usr/bin/env bash
# setup-gtd-structure.sh — Idempotent GTD structure bootstrap for Todoist
# Uses Todoist API v1. Requires TODOIST_API_TOKEN env var.
#
# What it creates (only if not already present):
#   Projects under "Getting Things Done":
#     - Next Actions
#     - Waiting For
#     - Someday Maybe
#     - Reference
#     - Archive
#   Labels:
#     - @computer, @phone, @errands, @home, @work, @online
#     - @agenda (prefix for agenda/person labels)
#     - #2min, #energy-low, #energy-high
#
# Existing projects (Work, Life, etc.) are preserved as Active Projects.

set -euo pipefail

API="https://api.todoist.com/api/v1"
TOKEN="${TODOIST_API_TOKEN:?ERROR: TODOIST_API_TOKEN env var not set}"
GTD_PROJECT_ID="6CrcvJ4hPxC5Mc2w"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RESET='\033[0m'

info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET}   $*"; }
skip()    { echo -e "${YELLOW}[SKIP]${RESET} $*"; }

todoist_get()  { curl -sf --url "$API/$1" --header "Authorization: Bearer $TOKEN"; }
todoist_post() { curl -sf --url "$API/$1" --header "Authorization: Bearer $TOKEN" \
                      --header "Content-Type: application/json" --data "$2"; }

# ─── Fetch existing data ────────────────────────────────────────────────────
info "Fetching existing projects..."
PROJECTS=$(todoist_get "projects")
EXISTING_NAMES=$(echo "$PROJECTS" | python3 -c "
import json,sys
data=json.load(sys.stdin)
projects = data.get('results', data) if isinstance(data, dict) else data
for p in projects:
    print(p['name'])
")

info "Fetching existing labels..."
LABELS=$(todoist_get "labels")
EXISTING_LABELS=$(echo "$LABELS" | python3 -c "
import json,sys
data=json.load(sys.stdin)
items = data.get('results', data) if isinstance(data, dict) else data
for l in items:
    print(l['name'])
")

# ─── Helper: create project if not exists ──────────────────────────────────
create_project_if_missing() {
    local name="$1"
    local parent_id="${2:-}"
    local color="${3:-charcoal}"

    if echo "$EXISTING_NAMES" | grep -qxF "$name"; then
        skip "Project '$name' already exists"
        return
    fi

    local payload
    if [[ -n "$parent_id" ]]; then
        payload="{\"name\":\"$name\",\"parent_id\":\"$parent_id\",\"color\":\"$color\"}"
    else
        payload="{\"name\":\"$name\",\"color\":\"$color\"}"
    fi

    local result
    result=$(todoist_post "projects" "$payload")
    local id
    id=$(echo "$result" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
    success "Created project '$name' (id=$id)"
}

# ─── Helper: create label if not exists ────────────────────────────────────
create_label_if_missing() {
    local name="$1"
    local color="${2:-charcoal}"

    if echo "$EXISTING_LABELS" | grep -qxF "$name"; then
        skip "Label '$name' already exists"
        return
    fi

    local payload="{\"name\":\"$name\",\"color\":\"$color\"}"
    local result
    result=$(todoist_post "labels" "$payload")
    local id
    id=$(echo "$result" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
    success "Created label '$name' (id=$id)"
}

# ─── GTD Projects ──────────────────────────────────────────────────────────
echo ""
info "Setting up GTD projects under 'Getting Things Done' (id=$GTD_PROJECT_ID)..."

create_project_if_missing "Next Actions"   "$GTD_PROJECT_ID" "blue"
create_project_if_missing "Waiting For"    "$GTD_PROJECT_ID" "yellow"
create_project_if_missing "Someday Maybe"  "$GTD_PROJECT_ID" "grape"
create_project_if_missing "Reference"      "$GTD_PROJECT_ID" "grey"
create_project_if_missing "Archive"        "$GTD_PROJECT_ID" "charcoal"

# ─── Context Labels ─────────────────────────────────────────────────────────
echo ""
info "Setting up context labels..."

# Context labels
create_label_if_missing "@computer"    "blue"
create_label_if_missing "@phone"       "green"
create_label_if_missing "@errands"     "red"
create_label_if_missing "@home"        "yellow"
create_label_if_missing "@work"        "orange"
create_label_if_missing "@online"      "teal"
create_label_if_missing "@agenda"      "grape"

# Energy/effort labels
create_label_if_missing "#2min"        "lime_green"
create_label_if_missing "#energy-low"  "grey"
create_label_if_missing "#energy-high" "red"

# ─── Summary ────────────────────────────────────────────────────────────────
echo ""
info "GTD structure setup complete!"
echo ""
echo "Your GTD layout:"
echo "  Inbox                    ← capture everything here first"
echo "  Getting Things Done/"
echo "    Next Actions           ← labelled with @context"
echo "    Waiting For            ← delegated / awaiting"
echo "    Someday Maybe          ← future possibilities"
echo "    Reference              ← info only, no action"
echo "    Archive                ← completed projects"
echo "  Work/                    ← Active Projects (existing)"
echo "  Life/                    ← Active Projects (existing)"
echo ""
echo "Context labels: @computer @phone @errands @home @work @online @agenda"
echo "Effort labels:  #2min #energy-low #energy-high"
