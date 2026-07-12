# ============================================================================
# CHECK PACKAGES  —  see whether your installed packages match the project list
# ============================================================================
# Tells you if anything is out of sync: a package you installed but haven't
# saved, or one the project needs but you haven't installed yet. It only
# reports; it changes nothing.
#
#   - If it says you're missing packages   -> Source scripts/get-packages.R
#   - If it says you have unrecorded ones   -> Source scripts/save-packages.R
#
# HOW TO RUN IT:
#   In RStudio, open this file and click "Source" (or press Cmd+Shift+S).

renv::status()
