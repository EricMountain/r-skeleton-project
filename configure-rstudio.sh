#!/usr/bin/env bash
#
# configure-rstudio.sh — apply this project's recommended RStudio settings.
#
# RStudio keeps its preferences in a small JSON file. This script writes the
# recommended values into it (creating it if needed), so you don't have to click
# through the Settings window. It only changes the specific keys below; anything
# else you've customised is left untouched.
#
# It sets:
#   - load_workspace       = false     don't reload leftover data at startup
#   - save_workspace       = "never"   don't save the workspace on exit
#   - enable_splash_screen = false     skip the RStudio logo screen
#   - rainbow_parentheses  = true      colour-match nested brackets
#   - git_exe_path         = <git>     where git lives (found automatically)
#   - panes.quadrants                  put the Console in the top-right pane
#
# IMPORTANT: quit RStudio before running this. RStudio rewrites its prefs file
# when it closes, so a running instance would overwrite these changes on exit.
#
# Usage:
#   ./configure-rstudio.sh
#
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required but not installed. Install it with: brew install jq" >&2
  exit 1
fi

PREFS="${HOME}/.config/rstudio/rstudio-prefs.json"
mkdir -p "$(dirname "$PREFS")"
[ -s "$PREFS" ] || echo '{}' >"$PREFS"

GIT_PATH="$(command -v git || true)"

# Build the updated preferences. Assigning to a nested path (.panes.quadrants)
# auto-creates parent objects; the `// default` fallbacks fill in the sibling
# pane fields only when the file doesn't already have them, so existing layouts
# are preserved apart from the quadrant order we care about.
jq \
  --arg git "$GIT_PATH" \
  '
  .load_workspace       = false
  | .save_workspace       = "never"
  | .enable_splash_screen = false
  | .rainbow_parentheses  = true
  | (if $git != "" then .git_exe_path = $git else . end)
  | .panes.quadrants      = ["Source", "Console", "TabSet1", "TabSet2", "HiddenTabSet", "Sidebar"]
  | .panes.tabSet1        = (.panes.tabSet1 // ["Environment", "History", "Connections", "Build", "VCS", "Tutorial", "Presentation"])
  | .panes.tabSet2        = (.panes.tabSet2 // ["Files", "Plots", "Packages", "Help", "Viewer", "Presentations"])
  | .panes.hiddenTabSet   = (.panes.hiddenTabSet // [])
  ' \
  "$PREFS" >"$PREFS.tmp" && mv "$PREFS.tmp" "$PREFS"

echo "✅ RStudio settings written to $PREFS"
if [ -z "$GIT_PATH" ]; then
  echo "   Note: 'git' wasn't found on PATH, so git_exe_path was left unchanged."
fi
echo "   (If RStudio was open, quit and reopen it for the changes to take effect.)"
