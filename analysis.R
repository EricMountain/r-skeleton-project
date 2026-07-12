# analysis.R — project entry point.
# Run non-interactively (like `python script.py` / `go run`):
#     Rscript analysis.R
# or in RStudio: Source with Echo (Cmd+Shift+Enter).
#
# As you add dependencies (library(...) calls), record them by running
# scripts/save-packages.R (or renv::snapshot()).

library(here)  # locates the project root automatically; paths work from anywhere

source(here("R", "stats.R"))
source(here("R", "plotting.R"))

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

# --- Plot ------------------------------------------------------------------
# Shows in the RStudio Plots pane when you Source this; saved to
# output/scatter.png when run non-interactively (e.g. Rscript). To also save it
# from RStudio, set SAVE_PLOTS=1 or pass save = TRUE. See R/plotting.R.
render_plot("scatter", plot(x, y, main = "x vs y", pch = 19))
