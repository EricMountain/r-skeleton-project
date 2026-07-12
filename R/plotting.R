# Plot output helper — sourced by analysis.R.
#
# Behaviour by default:
#   - Interactive (RStudio "Source", or the console): plots go to the RStudio
#     Plots pane. Nothing is written to disk.
#   - Non-interactive (Rscript, CI): plots are saved as PNG files under output/,
#     because there is no screen to draw on.
#
# You can override this easily, without editing code:
#   - SAVE_PLOTS=1 forces saving to PNG   (e.g. SAVE_PLOTS=1 in RStudio, then Source)
#   - SAVE_PLOTS=0 forces on-screen only
# ...or per call, by passing save = TRUE / FALSE to render_plot().

# Should plots be saved to PNG? Honour the SAVE_PLOTS env var if set, otherwise
# save only when we're NOT interactive.
should_save_plots <- function() {
  env <- Sys.getenv("SAVE_PLOTS", unset = "")
  if (nzchar(env)) {
    return(tolower(env) %in% c("1", "true", "yes", "on"))
  }
  !interactive()
}

#' Draw a plot to the screen, or save it to output/<name>.png.
#'
#' Write the plotting call as the second argument — it isn't evaluated until
#' this function draws it, either to the current (screen) device or into a PNG.
#'
#' @param name   file name (without extension) used when saving
#' @param expr   a plotting expression, e.g. plot(x, y). Wrap multiple lines
#'   in braces: { plot(...); lines(...) }
#' @param save   whether to save to PNG (default: see should_save_plots())
#' @param width,height pixel size of the saved PNG
render_plot <- function(name, expr,
                        save = should_save_plots(),
                        width = 800, height = 600) {
  if (isTRUE(save)) {
    dir.create(here::here("output"), showWarnings = FALSE)
    file <- here::here("output", paste0(name, ".png"))
    png(file, width = width, height = height)
    on.exit(dev.off(), add = TRUE)   # close the PNG device even if expr errors
    force(expr)                      # evaluate the plot into the PNG
    message("Wrote ", file)
  } else {
    force(expr)                      # evaluate the plot into the current device
  }
  invisible(NULL)
}
