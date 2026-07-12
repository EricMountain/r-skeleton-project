# analysis.R — project entry point.
# Run non-interactively (like `python script.py` / `go run`):
#     Rscript analysis.R
# or in RStudio: Source with Echo (Cmd+Shift+Enter).
#
# Uses only base R so it runs with no external packages. As you add
# dependencies (library(...) calls), record them with renv::snapshot().

# Locate project files relative to this script, so it works regardless of
# the current working directory. (The `here` package is a nicer alternative
# once you add it as a dependency.)
this_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- if (length(this_file)) dirname(normalizePath(this_file)) else getwd()

source(file.path(root, "R", "stats.R"))

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
out_dir <- file.path(root, "output")
dir.create(out_dir, showWarnings = FALSE)
png(file.path(out_dir, "scatter.png"), width = 800, height = 600)
plot(x, y, main = "x vs y", pch = 19)
invisible(dev.off())
cat(sprintf("\nWrote %s\n", file.path(out_dir, "scatter.png")))
