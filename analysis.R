# analysis.R — project entry point.
# Run non-interactively (like `python script.py` / `go run`):
#     Rscript analysis.R
# or in RStudio: Source with Echo (Cmd+Shift+Enter).
#
# As you add dependencies (library(...) calls), record them by running
# scripts/save-packages.R (or renv::snapshot()).

library(here)  # locates the project root automatically; paths work from anywhere

source(here("R", "stats.R"))

# --- Sample data -----------------------------------------------------------
x <- c(5, 7, 8, 7, 2, 2, 9, 4, 11, 12, 9, 6)
y <- c(99, 86, 87, 88, 111, 103, 87, 94, 78, 77, 85, 86)

# --- Analysis --------------------------------------------------------------
sx <- summary_stats(x)
sy <- summary_stats(y)
r  <- correlation(x, y)

cat("Summary of x:\n"); str(sx)
cat("\nSummary of y:\n"); str(sy)
cat(sprintf("\nPearson correlation(x, y): %.4f\n", r))

# --- Output artifact -------------------------------------------------------
# Write a plot to disk rather than relying on an interactive device, so the
# script produces the same result under Rscript, RStudio, or CI.
dir.create(here("output"), showWarnings = FALSE)
png(here("output", "scatter.png"), width = 800, height = 600)
plot(x, y, main = "x vs y", pch = 19)
invisible(dev.off())
cat(sprintf("\nWrote %s\n", here("output", "scatter.png")))
