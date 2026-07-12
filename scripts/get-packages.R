# ============================================================================
# GET PACKAGES  —  run this once after opening the project for the first time
# ============================================================================
# Downloads and installs the exact package versions this project needs, into a
# private folder inside the project (it won't touch the rest of your computer).
#
# HOW TO RUN IT:
#   In RStudio, open this file and click the "Source" button (top-right of the
#   editor), or press Cmd+Shift+S.
#
# You only need to do this once per computer, or again if a teammate adds a new
# package. It is always safe to re-run.

renv::restore(prompt = FALSE)
cat("\n✅ All packages are installed. You're ready to run the analysis.\n")
