#!/usr/bin/env bash
# install.sh — Install gtd-todoist plugin into ~/.claude/
# Run from the gtd-todoist repo root.

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; RESET='\033[0m'
info()    { echo -e "${BLUE}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}[OK]${RESET}   $*"; }

# ─── Skills ─────────────────────────────────────────────────────────────────
info "Installing skills..."
mkdir -p "$CLAUDE_DIR/skills"
for skill_dir in "$PLUGIN_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    dest="$CLAUDE_DIR/skills/$skill_name"
    mkdir -p "$dest"
    cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
    success "Skill: $skill_name"
done

# ─── Commands ───────────────────────────────────────────────────────────────
info "Installing commands..."
mkdir -p "$CLAUDE_DIR/commands"
for cmd_file in "$PLUGIN_DIR/commands"/*.md; do
    cmd_name=$(basename "$cmd_file" .md)
    dest="$CLAUDE_DIR/commands/gtd-todoist:${cmd_name}.md"
    cp "$cmd_file" "$dest"
    success "Command: /gtd-todoist:${cmd_name}"
done

# ─── Agents ─────────────────────────────────────────────────────────────────
info "Installing agents..."
mkdir -p "$CLAUDE_DIR/agents"
for agent_file in "$PLUGIN_DIR/agents"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    dest="$CLAUDE_DIR/agents/${agent_name}.md"
    cp "$agent_file" "$dest"
    success "Agent: $agent_name"
done

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
success "gtd-todoist plugin installed!"
echo ""
echo "Installed:"
echo "  Skills:   $(ls "$CLAUDE_DIR/skills" | grep -c 'gtd-' || echo 0) GTD skills"
echo "  Commands: /gtd-todoist:capture, :process-inbox, :weekly-review, :daily-plan, :waiting-for"
echo "  Agent:    todoist-gtd-assistant"
echo ""
echo "Next step: Set TODOIST_API_TOKEN in your shell profile:"
echo "  export TODOIST_API_TOKEN=<your-token>"
echo ""
echo "Then run the GTD structure bootstrap:"
echo "  $PLUGIN_DIR/scripts/setup-gtd-structure.sh"
