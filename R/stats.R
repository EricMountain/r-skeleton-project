# Reusable functions for the project.
# Sourced by analysis.R. Keep this file free of top-level side effects
# (no printing, no plotting) — it should only define things.

#' Summary statistics for a numeric vector.
#'
#' @param v numeric vector
#' @return named list of n, mean, sd, min, max
summary_stats <- function(v) {
  stopifnot(is.numeric(v))
  list(
    n    = length(v),
    mean = mean(v),
    sd   = sd(v),
    min  = min(v),
    max  = max(v)
  )
}

#' Pearson correlation of two numeric vectors of equal length.
correlation <- function(x, y) {
  stopifnot(length(x) == length(y))
  cor(x, y)
}
