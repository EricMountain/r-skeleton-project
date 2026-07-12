# ============================================================================
# SAVE PACKAGES  —  run this after you add a new package to the project
# ============================================================================
# When you start using a new package (a new `library(something)` line in your
# code), first install it with, e.g.:
#
#     renv::install("janitor")
#
# ...then Source THIS file to record it, so the project remembers the exact
# version. This updates the "renv.lock" file (the project's package list).
#
# HOW TO RUN IT:
#   In RStudio, open this file and click "Source" (or press Cmd+Shift+S).

renv::snapshot(prompt = FALSE)
cat("\n✅ Package list saved to renv.lock.\n")
