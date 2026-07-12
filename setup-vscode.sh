#!/usr/bin/env bash
#
# setup-vscode.sh — set up VSCode for working on this project.
#
# The project's editor settings live in .vscode/ and are already in place (they
# travel with the project). This script does the two machine-level things those
# settings assume:
#
#   1. Installs the VSCode extensions (the R language support + R debugger).
#   2. Installs the R packages the extension relies on, into this project:
#        - languageserver : code completion, diagnostics, formatting
#        - httpgd         : the plot viewer used by .vscode/settings.json
#      These are editor tools, not part of the analysis, so they're kept OUT of
#      renv.lock (renv is configured to ignore them). Run this once per machine.
#
# Usage:
#   ./setup-vscode.sh
#
set -euo pipefail

SKELETON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 1. VSCode extensions --------------------------------------------------
if command -v code >/dev/null 2>&1; then
  echo "Installing VSCode extensions..."
  code --install-extension reditorsupport.r --force
  code --install-extension rdebugger.r-debugger --force
else
  echo "Note: the 'code' command wasn't found, so extensions weren't installed." >&2
  echo "In VSCode, open the Command Palette (Cmd+Shift+P) and run" >&2
  echo "\"Shell Command: Install 'code' command in PATH\", then re-run this script." >&2
  echo "(Or just open the project in VSCode and accept the recommended extensions.)" >&2
fi

# --- 2. R packages for the editor ------------------------------------------
if command -v Rscript >/dev/null 2>&1; then
  echo "Installing R editor packages (languageserver, httpgd)..."
  echo "This can take a few minutes the first time (httpgd is compiled)."
  ( cd "$SKELETON_DIR" && Rscript -e 'renv::install(c("languageserver", "httpgd"))' )
else
  echo "Error: 'Rscript' not found. Install R first (see the README)." >&2
  exit 1
fi

echo
echo "✅ VSCode is set up. Open the project with:  code \"$SKELETON_DIR\""
