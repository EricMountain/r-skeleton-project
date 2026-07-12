#!/usr/bin/env bash
#
# new-project.sh — create a brand-new R project from this skeleton.
#
# Copies this skeleton into a new (empty or not-yet-existing) target directory,
# deliberately leaving behind the things that must NOT travel between projects:
#   - git history            (.git)          -> each project gets its own
#   - generated output        (output/)       -> results, not source
#   - the package library     (renv/library)  -> machine-specific; rebuilt with
#                                                scripts/get-packages.R
#   - R session junk          (.Rhistory, .RData, .Rproj.user, ...)
#   - scratch/experiment files
#
# It then renames the .Rproj to match the new folder, fixes up the project name
# in the docs, and initialises a fresh git repository on the `main` branch.
#
# Usage:
#   ./new-project.sh <target-directory>
#
# Example:
#   ./new-project.sh ~/Projects/sales-report
#
set -euo pipefail

# Directory this script lives in = the skeleton to copy from.
SKELETON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$(basename "${BASH_SOURCE[0]}")"

# --- make sure rsync is available ------------------------------------------
if ! command -v rsync >/dev/null 2>&1; then
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Error: 'rsync' is not installed." >&2
    echo "Automatic install is only supported on macOS. Please install rsync" >&2
    echo "with your system's package manager and re-run this script." >&2
    exit 1
  fi
  if ! command -v brew >/dev/null 2>&1; then
    echo "Error: 'rsync' is not installed, and Homebrew ('brew') was not found." >&2
    echo "Install Homebrew from https://brew.sh (or install rsync yourself)," >&2
    echo "then re-run this script." >&2
    exit 1
  fi
  echo "'rsync' not found — installing it with Homebrew..."
  brew install rsync
fi

# --- arguments -------------------------------------------------------------
if [ "$#" -ne 1 ]; then
  echo "Usage: $SELF <target-directory>" >&2
  exit 64
fi
TARGET_ARG="$1"

# --- validate the target ---------------------------------------------------
if [ -e "$TARGET_ARG" ] && [ -n "$(ls -A "$TARGET_ARG" 2>/dev/null || true)" ]; then
  echo "Error: target '$TARGET_ARG' already exists and is not empty." >&2
  echo "Choose a new directory name, or empty the existing one first." >&2
  exit 1
fi
mkdir -p "$TARGET_ARG"
TARGET="$(cd "$TARGET_ARG" && pwd)"   # absolute, normalised

if [ "$TARGET" = "$SKELETON_DIR" ]; then
  echo "Error: the target is the skeleton itself." >&2
  exit 1
fi

NEW_NAME="$(basename "$TARGET")"
# Old project name, taken from the skeleton's own .Rproj
OLD_RPROJ="$(cd "$SKELETON_DIR" && ls *.Rproj 2>/dev/null | head -n1 || true)"
OLD_NAME="${OLD_RPROJ%.Rproj}"

echo "Creating new project '$NEW_NAME' at $TARGET"

# --- copy the skeleton -----------------------------------------------------
# rsync patterns containing a slash are anchored to the project root; bare 
# names match at any depth.
rsync -a \
  --exclude=".git/" \
  --exclude="output/" \
  --exclude="renv/library/" \
  --exclude="renv/local/" \
  --exclude="renv/cellar/" \
  --exclude="renv/staging/" \
  --exclude="renv/sandbox/" \
  --exclude="renv/python/" \
  --exclude=".Rproj.user/" \
  --exclude=".Rhistory" \
  --exclude=".RData" \
  --exclude=".Ruserdata" \
  --exclude=".DS_Store" \
  --exclude="$SELF" \
  "$SKELETON_DIR"/ "$TARGET"/

# --- rename the .Rproj and fix the project name in the docs ----------------
if [ -n "$OLD_NAME" ] && [ -f "$TARGET/$OLD_NAME.Rproj" ]; then
  if [ "$NEW_NAME" != "$OLD_NAME" ]; then
    mv "$TARGET/$OLD_NAME.Rproj" "$TARGET/$NEW_NAME.Rproj"
    # Update references to the old name (e.g. "R-test.Rproj", "R-test/") in the
    # copied Markdown so the instructions match the new project.
    find "$TARGET" -maxdepth 1 -name "*.md" -type f \
      -exec perl -pi -e "s/\Q$OLD_NAME\E/$NEW_NAME/g" {} +
  fi
fi

# --- fresh git repository on `main` ----------------------------------------
if git -C "$TARGET" init -b main >/dev/null 2>&1; then
  :   # git >= 2.28
else
  git -C "$TARGET" init >/dev/null
  git -C "$TARGET" symbolic-ref HEAD refs/heads/main
fi

echo
echo "✅ Done. Next steps:"
echo "   1. open \"$TARGET/$NEW_NAME.Rproj\"          # opens the project in RStudio"
echo "   2. In RStudio, Source scripts/get-packages.R  # install the packages"
echo "   3. Start editing analysis.R"
