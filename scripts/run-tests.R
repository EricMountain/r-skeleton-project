# run-tests.R — run a stdin -> stdout script against recorded test cases.
#
# A "script under test" is any program that reads its input on STDIN and writes
# its answer to STDOUT. Test cases live in:
#
#     tests/<script-name>/input.1   output.1
#                         input.2   output.2
#                         ...
#
# where <script-name> is the script's file name without extension, and X in
# input.X / output.X is an integer. For each input.X the scaffold runs the
# script with that file on stdin, captures stdout, and compares it to output.X.
# The comparison is exact: stdout must equal output.X byte for byte (including
# whitespace and the final newline).
#
# USAGE
#   In RStudio: Source this file, then call, e.g.:
#       run_tests("examples/sum.R")
#   From a terminal:
#       Rscript scripts/run-tests.R examples/sum.R
#
# It prints a per-test result and a detailed diff for every failure, and returns
# (invisibly) a data.frame of results. Run non-interactively it exits non-zero if
# any test fails, so it works in CI too.
#
# By default an R script (.R) is run with Rscript; anything else is executed
# directly (so it must be executable / have a shebang). Override with `command`.

run_tests <- function(script,
                      tests_dir      = NULL,
                      command        = NULL,
                      max_diff_lines = 50) {

  is_absolute  <- function(p) grepl("^(/|~)", p)
  project_root <- function() {
    if (requireNamespace("here", quietly = TRUE)) here::here() else getwd()
  }
  resolve <- function(p) if (is_absolute(p)) path.expand(p) else file.path(project_root(), p)

  script_path <- resolve(script)
  if (!file.exists(script_path)) stop("Script not found: ", script_path, call. = FALSE)

  name <- tools::file_path_sans_ext(basename(script))
  tests_dir <- if (is.null(tests_dir)) file.path(project_root(), "tests", name) else resolve(tests_dir)
  if (!dir.exists(tests_dir)) stop("No tests directory: ", tests_dir, call. = FALSE)

  # How to invoke the script under test.
  if (is.null(command)) {
    command <- if (tolower(tools::file_ext(script_path)) == "r") {
      c(file.path(R.home("bin"), "Rscript"), script_path)
    } else {
      script_path
    }
  }
  prog <- command[[1]]; prog_args <- command[-1]

  # Collect input.X files, ordered by the integer X (so input.10 comes after 2).
  inputs <- list.files(tests_dir, pattern = "^input\\.[0-9]+$")
  if (length(inputs) == 0L) {
    message("No test inputs in ", tests_dir, " (expected input.1, input.2, ...).")
    return(invisible(data.frame()))
  }
  nums   <- as.integer(sub("^input\\.", "", inputs))
  ord    <- order(nums)
  inputs <- inputs[ord]; nums <- nums[ord]

  read_raw <- function(f) {
    n <- file.info(f)$size
    if (is.na(n) || n == 0) raw(0) else readBin(f, what = "raw", n = n)
  }
  rule <- strrep("─", 60)

  cat(sprintf("Running %d test(s) for '%s'\n", length(inputs), basename(script_path)))
  cat(sprintf("  script:    %s\n", script_path))
  cat(sprintf("  tests dir: %s\n\n", tests_dir))

  results <- vector("list", length(inputs))
  for (i in seq_along(inputs)) {
    x             <- nums[i]
    input_file    <- file.path(tests_dir, inputs[i])
    expected_file <- file.path(tests_dir, paste0("output.", x))

    if (!file.exists(expected_file)) {
      cat(sprintf("✗ Test %d  — missing expected file 'output.%d'\n", x, x))
      results[[i]] <- data.frame(test = x, passed = FALSE, status = NA_integer_,
                                 reason = "missing expected output", stringsAsFactors = FALSE)
      next
    }

    out_tmp <- tempfile(); err_tmp <- tempfile()
    status  <- suppressWarnings(system2(prog, args = prog_args, stdin = input_file,
                                        stdout = out_tmp, stderr = err_tmp))
    actual_raw   <- read_raw(out_tmp)
    expected_raw <- read_raw(expected_file)
    stderr_txt   <- readLines(err_tmp, warn = FALSE)
    exp_lines    <- readLines(expected_file, warn = FALSE)   # for a readable diff
    act_lines    <- readLines(out_tmp,       warn = FALSE)
    unlink(c(out_tmp, err_tmp))

    ok <- identical(actual_raw, expected_raw)   # exact, byte-for-byte
    if (ok) {
      cat(sprintf("✓ Test %d\n", x))
      reason <- ""
    } else {
      cat(rule, "\n", sep = "")
      cat(sprintf("✗ Test %d   (input.%d → output.%d)\n", x, x, x))
      cat(sprintf("  exit status: %d%s\n", status, if (status != 0) "   <-- non-zero" else ""))
      cat(paste0("  ", byte_notes(expected_raw, actual_raw)), sep = "\n"); cat("\n")
      ld <- format_line_diff(exp_lines, act_lines, max_diff_lines)
      if (length(ld)) {
        cat(ld, sep = "\n"); cat("\n")
      } else {
        cat("    (lines match once split on newlines — the difference is invisible:\n")
        cat("     trailing whitespace, a trailing newline, or CRLF vs LF; see bytes above)\n")
      }
      if (length(stderr_txt)) {
        cat("  stderr:\n")
        cat(paste0("    ", utils::head(stderr_txt, 20L)), sep = "\n"); cat("\n")
      }
      reason <- if (status != 0) sprintf("exit %d, output mismatch", status) else "output mismatch"
    }
    results[[i]] <- data.frame(test = x, passed = ok, status = status,
                               reason = reason, stringsAsFactors = FALSE)
  }

  res   <- do.call(rbind, results)
  npass <- sum(res$passed); nfail <- sum(!res$passed)
  cat(sprintf("\n%d test(s): %d passed, %d failed\n", nrow(res), npass, nfail))
  invisible(res)
}

# Byte-level notes explaining an exact-comparison failure, especially for
# differences a line diff can't show (final newline, CRLF vs LF, total size).
byte_notes <- function(expected, actual) {
  LF <- as.raw(0x0a); CR <- as.raw(0x0d)
  ends_nl  <- function(r) length(r) > 0L && r[length(r)] == LF
  has_crlf <- function(r) length(r) > 1L && any(r[-length(r)] == CR & r[-1L] == LF)

  notes <- sprintf("expected %d byte(s), got %d", length(expected), length(actual))
  if (ends_nl(expected) != ends_nl(actual)) {
    notes <- c(notes, sprintf("final newline: expected %s, actual %s",
                              if (ends_nl(expected)) "present" else "absent",
                              if (ends_nl(actual))   "present" else "absent"))
  }
  if (has_crlf(expected) != has_crlf(actual)) {
    notes <- c(notes, sprintf("line endings: expected %s, actual %s",
                              if (has_crlf(expected)) "CRLF" else "LF",
                              if (has_crlf(actual))   "CRLF" else "LF"))
  }
  notes
}

# Line-by-line diff of two character vectors. Not a minimal-edit (LCS) diff — it
# compares position by position, which is clear and predictable for test output.
format_line_diff <- function(expected, actual, max_show = 50L) {
  n <- max(length(expected), length(actual))
  out <- character(0); count <- 0L
  for (i in seq_len(n)) {
    e <- if (i <= length(expected)) expected[i] else NA_character_
    a <- if (i <= length(actual))   actual[i]   else NA_character_
    if (!identical(e, a)) {
      count <- count + 1L
      if (count <= max_show) {
        out <- c(out,
          sprintf("    line %d:", i),
          sprintf("      - expected: %s", if (is.na(e)) "<no such line>" else e),
          sprintf("      + actual:   %s", if (is.na(a)) "<no such line>" else a))
      }
    }
  }
  if (count > max_show) out <- c(out, sprintf("    ... and %d more differing line(s)", count - max_show))
  out
}

# --- run automatically when executed non-interactively (e.g. via Rscript) ---
#     Rscript scripts/run-tests.R <script> [tests_dir]
if (!interactive()) {
  .args <- commandArgs(trailingOnly = TRUE)
  if (length(.args) >= 1L) {
    .res <- run_tests(.args[[1L]], tests_dir = if (length(.args) >= 2L) .args[[2L]] else NULL)
    if (nrow(.res) && any(!.res$passed)) quit(status = 1L, save = "no")
  }
} else {
  message("Loaded run_tests(). Example: run_tests(\"examples/sum.R\")  ",
          "# reads cases from tests/<script-name>/")
}
