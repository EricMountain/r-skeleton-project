# R for Go/Python/C Developers — Notes

Living document. Concepts, workflows, and setup notes for R, framed for someone
coming from Go, Python, and C. Iterate and augment over time.

## Sessions, workspaces, and images

An R **session** is a running REPL process — like a live Python interpreter. It
holds an in-memory environment (the **global environment**, `.GlobalEnv`) full
of variables and functions you've defined.

- **Workspace** = that in-memory global environment. It's just the set of
  objects currently bound in your session. `ls()` lists them (like `dir()` in
  Python), `rm()` removes them.
- **Image** = a *serialized snapshot* of the workspace written to disk,
  conventionally a file named `.RData`. It's a binary dump of your variables —
  closest analogy is Python's `pickle` of your whole namespace, or a core dump
  you can reload. `save.image("file.RData")` writes one; `load("file.RData")`
  restores it into a session.

**The classic footgun:** when you quit R (`q()`), it asks *"Save workspace
image?"*. If yes, it writes `.RData` in the working directory, and the **next**
R started from that directory silently reloads it. This makes sessions
statefully "remember" old variables, which hurts reproducibility.

**Recommendation: turn this off.**
- Start R with `R --no-save --no-restore`, or
- RStudio: *Tools → Global Options → General → uncheck "Restore .RData into
  workspace at startup"*, and set "Save workspace to .RData on exit" to *Never*.

You want every run to start from a clean process, like `go run` or
`python script.py`.

Related: `.Rhistory` is a text log of typed commands (like `~/.bash_history`),
separate from the workspace image.

## Does `install.packages()` persist?

Yes. `install.packages("languageserver")` downloads and compiles the package
into a **library** — a directory on disk (see `.libPaths()` for locations,
checked in order). Persistent, filesystem-level install, like `pip install`
into site-packages. **Not** tied to the session; every future R invocation using
that library sees it.

What is *not* persistent: `library(languageserver)` (loading/attaching it into
your session's namespace). That's the equivalent of `import` — done per session,
affecting only the running process.

**So: install once, load per session.**

Nuances:
- There's a **user library** (per-user, no admin rights) and a **system
  library**. Installs go to the user library if the system one isn't writable.
- Base R has **no built-in virtualenv/project isolation**. All projects share
  the same library by default — like `pip install` with no venv. The fix is
  **`renv`** (per-project libraries + lockfile). This is the idiomatic answer to
  "how do I get reproducible dependencies like `go.mod` / `requirements.txt` +
  venv."

## RStudio: run a whole script vs. source vs. blocks

Three execution granularities:

1. **Run selected line(s) / block** — `Cmd+Enter`. Sends the current line or
   selection to the console and echoes it there, advancing the cursor.
   Interactive, line-by-line.
2. **Source** — `source("script.R")`, button *Source* (`Cmd+Shift+S`). Executes
   the entire file in one shot **without echoing** each statement, and top-level
   auto-printing is suppressed — a bare `x` on a line won't print. Runs the file
   for its side effects, like importing a Python module.
3. **Source with Echo** — `Cmd+Shift+Enter`. Runs the whole file *and* echoes
   each statement and its printed output to the console, as if you'd typed the
   lines. Usually what people mean by "just run my script and show me
   everything."

"Run a script rather than source it" maps to **Source with Echo** vs. plain
**Source**. The difference from running blocks is only that it does the whole
file at once instead of where the cursor is.

**Gotcha:** *auto-printing* (typing `x` to see it) only happens at the
interactive top level and with echo, **not** under plain `source()`. In real
scripts, always call `print()` explicitly rather than relying on auto-print.

## VSCode with the R extension: run a script and see output

Install the **REditorSupport R extension**, plus in R: **`languageserver`**
(completion/diagnostics) and ideally **`httpgd`** (plots in a panel/browser).

Ways to run:

- **Whole file, non-interactively (closest to `python script.py` / `go run`):**
  ▶ "Run" button or a terminal task, effectively `Rscript yourfile.R`. `Rscript`
  is R's batch front-end — no REPL, no saved workspace, output to stdout/stderr
  in the integrated terminal. Cleanest mental match.
- **Interactively in an R terminal:** the extension sends code to a live R
  session. `Cmd+Enter` / `Ctrl+Enter` sends the current line/selection; "Run
  Source" sends the whole file with echo. Output in the R terminal pane, plots
  in the httpgd viewer.

Command-line-only check, in the integrated terminal:
```bash
Rscript yourfile.R
```
Same as `python`. Note `Rscript` does **not** auto-print top-level expressions,
so use `print()`/`cat()`:
- `cat()` — raw output, like `fputs` (no quoting/newline).
- `print()` — structured display.

## Suggested development setup

For someone from Go/Python/C who values reproducibility and CLI ergonomics:

- **Editor:** RStudio (batteries-included: best plot/data-viewer/debugger
  integration) or VSCode + REditorSupport (better if already living in VSCode).
  Both fine; RStudio has the smoothest R-specific tooling.
- **In VSCode, install:** `languageserver` (LSP), `httpgd` (plots), and set the
  extension to use **`radian`** as the terminal — a nicer R REPL (syntax
  highlighting, multiline editing; Python-based drop-in, `pip install radian`).
- **Reproducibility (do this):**
  - Disable workspace save/restore so every run is clean.
  - Use **RStudio Projects** (`.Rproj`) or a project dir + the **`here`** package
    to avoid absolute paths / `setwd()`.
  - Use **`renv`** per project: `renv::init()` creates a project-local library
    and `renv.lock` (the `go.sum`/lockfile equivalent); `renv::snapshot()` /
    `renv::restore()` manage it.
- **Package sources:** CRAN is the default registry (like PyPI). Some packages
  come from Bioconductor or GitHub (`remotes::install_github()`).
- **Scripts vs. notebooks:** plain `.R` files run with `Rscript` for
  reproducible/CLI work. For literate/report work, **R Markdown** or **Quarto**
  (`.qmd`) — Quarto is the modern successor, text-first, Jupyter-like spirit.
- **Style/lint:** `styler` (auto-format, like `gofmt`) and `lintr` (linter).

Minimal reproducible-project skeleton:
```
myproj/
  myproj.Rproj        # if using RStudio
  renv.lock           # locked deps
  renv/               # project library
  R/                  # your .R source files
  analysis.R          # entry point, run with: Rscript analysis.R
```

**Mindset note:** R defaults toward stateful, interactive, "keep your workspace
around" workflows — the opposite of the clean-process habits from Go/Python/C.
Fight that default (no `.RData` restore, use `renv`, run via `Rscript`), and R
will feel much more predictable.

## Quick reference / glossary

| R | Closest analogy |
|---|---|
| session / REPL | live `python` interpreter |
| workspace (`.GlobalEnv`) | current in-memory namespace (variables...) / global scope |
| image (`.RData`) | `pickle` of whole namespace |
| `.Rhistory` | `~/.bash_history` |
| library (`.libPaths()`) | site-packages directory |
| `install.packages()` | `pip install` |
| `library(pkg)` | `import pkg` |
| `renv` | venv + lockfile (`go.mod`/`requirements.txt`) |
| CRAN | PyPI |
| `Rscript file.R` | `python file.R` / `go run` |
| `styler` / `lintr` | `gofmt` / linter |
