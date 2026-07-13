# How to Use This Project

This is a small, self-contained R project. It's set up so that it "just works"
the same way on any computer, with as few surprises as possible.

The project can be cloned using the `new-project.sh` script. This creates a copy
of the current project so that you can work on something new without overwriting
a previous project. The new project is its own git repository.

---

## Part 1 · One-time setup (Mac)

These steps assume you're on a Mac and already have Homebrew (`brew`),
iTerm (a terminal app, others can be used), and `jq` installed. Everything below is typed into
iTerm: copy a line, paste it, and press Return. A few steps run a **script that
ships with this project** (e.g. `./configure-rstudio.sh`) — for those, first
`cd` into the project folder (the one containing this README).

You'll work in one of two editors — RStudio or VSCode. First do the
common step (1.1), then follow the section for your editor. You can set up both.

### 1.1 Install R (needed either way)

R is the language itself. Install it first:

```bash
brew install r
```

Check it worked:

```bash
R --version
```

You should see something like `R version 4.6.1`. If so, you're good. Now pick
your editor:

- RStudio — an all-in-one app built for R (best plots, data viewer, and
  debugger; easiest if you're new). → **section 1.2**.
- VSCode — good if you already use it for other languages. → **section 1.3**.

### 1.2 RStudio

#### Install RStudio

```bash
brew install --cask rstudio
```

#### Configure RStudio (one command)

Rather than clicking through the Settings window, this project includes a script
that applies the recommended settings.

Quit RStudio if it's open, then from inside the project folder run:

```bash
./configure-rstudio.sh
```

That sets, all at once:

- Start clean every time — R won't reload or save leftover data between
  sessions (the biggest source of confusing bugs; this makes every run start
  fresh, the way Python does).
- Skip the splash screen — opens straight to your work.
- Rainbow parentheses — colours each level of nested brackets so it's easy
  to see which `(` matches which `)`.
- Console in the top-right — puts the editor and Console side by side.
- Git path — tells RStudio where `git` lives.

> Why a script for the Git path? If you set it through RStudio's own UI, it
> records the exact Homebrew version path (e.g. `.../git/2.54.0/bin/git`),
> which breaks the next time `git` is upgraded. The script records the stable
> `git` location instead. (You can still change any of these later in
> **RStudio → Settings…**.)

That's the RStudio setup done — skip to **Part 2**.

### 1.3 VSCode

#### Install VSCode

```bash
brew install --cask visual-studio-code
```

If typing `code` in iTerm says "command not found", open VSCode, press
`Cmd+Shift+P`, and run `"Shell Command: Install 'code' command in PATH"`.

#### Configure VSCode (one command)

From inside the project folder run:

```bash
./setup-vscode.sh
```

That does two things:

- Installs the VSCode extensions — the R language support and the R
  debugger.
- Installs the R packages the extension needs, into this project — the
  equivalent of running, in R:

  ```r
  install.packages(c("languageserver", "httpgd"))
  ```

  `languageserver` powers code completion and diagnostics; `httpgd` is the plot
  viewer. These are editor tools, not part of the project, so they're
  deliberately kept out of the project's package list (`renv.lock`).

The project's VSCode settings themselves already live in the `.vscode/` folder
(so plots open with `httpgd`, and the R session is tracked). They travel with
the project — including to new projects you create with `new-project.sh` — so
you don't have to configure anything by hand.

> Optional: for a nicer console, install [`radian`](https://github.com/randy3k/radian)
> (`pip install radian`) and point VSCode at it via the `r.rterm.mac` setting.

---

## Part 2 · Using the project in RStudio

This part is written for RStudio. If you use VSCode, skip to **Part 3**,
which covers the same operations there.

### 2.1 Open the project

Always open the project via the `.Rproj` file, not by opening individual files —
this makes sure everything points at the right place.

#### In Finder

Navigate to the directory containing the project, then open the `.RProj` file.

#### In iTerm

```bash
open ~/Projects/r-skeleton-project/r-skeleton-project.Rproj
```

This opens the folder _as a project_ in RStudio.

### 2.2 First time only: get the packages

A "package" is a bundle of extra R functions someone else wrote (like a Python
library you'd `pip install`). This project lists exactly which packages and
which versions it needs, in a file called `renv.lock`. You install them all in
one step:

1. In RStudio's `Files` panel (bottom-right), click into the `scripts` folder.
2. Open `get-packages.R`.
3. Click the `Source` button at the top-right of the editor (or press
   `Cmd+Shift+S`).

Wait for it to finish. When you see `✅ All packages are installed`, you're done.
The packages install into a private folder inside this project, so they can't
clash with anything else on your computer.

### 2.3 Run the analysis

1. Open `scripts/run-analysis.R`.
2. Click `Source` (or `Cmd+Shift+S`).

You'll see numbers printed in the `Console` (bottom-left), and a chart appears
in the `Plots` pane (bottom-right). That's it.

> Saving a chart to a file. In RStudio, charts show in the Plots pane and
> aren't written to disk. To also save them as PNG files in the `output` folder,
> type `Sys.setenv(SAVE_PLOTS = 1)` in the Console once, then Source the script
> again. (When the project is run non-interactively with `Rscript`, charts are
> always saved, since there's no Plots pane to draw on.)
>
> Why "Source" and not just running lines? `Source` runs the whole file from
> top to bottom in one go, the way a finished script is meant to run. You can
> also step through a file line by line with `Cmd+Return` while you're
> experimenting — but for running the finished thing, use Source.

---

## Part 3 · Using the project in VSCode

The same operations as Part 2, for VSCode. This assumes you did the VSCode
setup in **Part 1.3** (the R extensions plus `languageserver` / `httpgd`).

### 3.1 Open the project

VSCode works at the folder level — there's no `.Rproj` to open. From iTerm:

```bash
code ~/Projects/r-skeleton-project
```

The R extension starts automatically. If VSCode offers to install
recommended extensions, accept them — that's the R support this project
expects. (The project's paths still work in VSCode: the tools find the project
by its folder, which is marked by the `.Rproj` file sitting in it.)

### 3.2 First time only: get the packages

Open a terminal inside VSCode (menu `Terminal → New Terminal`, or press
`` Ctrl+` ``), then run:

```bash
Rscript scripts/get-packages.R
```

Wait for `✅ All packages are installed`. As in RStudio, the packages install
into a private folder inside the project, so they can't clash with anything else.

### 3.3 Run the analysis

There are two ways, depending on whether you want to see or save the chart
— this mirrors the two modes described in the plotting helper.

#### Seeing the chart (interactive — the chart opens in a viewer)

1. Open **`scripts/run-analysis.R`** (or `analysis.R`).
2. Click the **▷ "Run Source"** icon at the top-right of the editor — or open the
   Command Palette (`Cmd+Shift+P`) and run **"R: Run Source"**.

The first time, this starts an R session in the terminal. The numbers print
there, and the chart opens in a **plot panel** (drawn by `httpgd`). Keep that R
session running — it's your interactive console, the equivalent of RStudio's.

#### Save chart to a file (non-interactive)

In the VSCode terminal, run:

```bash
Rscript scripts/run-analysis.R
```

The numbers print in the terminal and the chart is written to
`output/scatter.png`.

> Saving a chart while working interactively. Same rule as RStudio: in the R
> session, type `Sys.setenv(SAVE_PLOTS = 1)` once, then run the file again to
> also write PNGs to the `output` folder.

### 3.4 The helper scripts in VSCode

Wherever Part 2 or the table below says "Source the file", in VSCode you instead
either click `▷ Run Source`, or run `Rscript scripts/<name>.R` in the terminal.
For example, to record a newly added package (see "Adding a new package" below),
run `Rscript scripts/save-packages.R`.

---

## The helper scripts

Everything you routinely need is a file in the `scripts/` folder. Run one to do
its job — `Source` it in RStudio, or `▷ Run Source` / `Rscript scripts/<name>.R`
in VSCode (see Part 3). You never have to memorise commands.

| Open this file            | What it does                                             | When to use it                                  |
| ------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| `scripts/get-packages.R`  | Installs all packages the project needs                  | Once, the first time you open the project       |
| `scripts/run-analysis.R`  | Runs the main analysis and shows results                 | Any time you want to see the output             |
| `scripts/save-packages.R` | Records a package you just added into `renv.lock`        | After you add a new `library(...)` to your code |
| `scripts/check-packages.R`| Reports whether your packages match the project list     | Any time you're unsure things are in sync       |

### Adding a new package

Say you want to use a package called `janitor`. Two steps:

1. In the R `Console` (RStudio: bottom-left; VSCode: the R terminal), type and
   press Return:

   ```r
   renv::install("janitor")
   ```

2. Add `library(janitor)` to your script where you use it, then run
   `scripts/save-packages.R` (Source in RStudio, or `Rscript scripts/save-packages.R`
   in VSCode) to record the new package.

---

## Testing a script

For scripts that read input on **stdin** and write their answer to **stdout**,
there's a small test runner: `scripts/run-tests.R`. It runs your script against
recorded input/output pairs and reports any mismatches.

**Layout.** Put test cases in `tests/<script-name>/`, named `input.X` and
`output.X` (X is an integer). For a script `examples/sum.R`:

```text
tests/sum/
├── input.1     output.1
├── input.2     output.2
└── input.3     output.3
```

Each `input.X` is fed to the script on stdin; its stdout is compared to
`output.X` **exactly, byte for byte** — including whitespace and the final
newline. (So make sure each `output.X` ends the way your script really prints it;
most scripts end with a trailing newline.) A worked example (`examples/sum.R` —
sums the numbers it reads) ships with the skeleton; delete `examples/` and
`tests/sum/` once you don't need it.

**Run the tests** — in RStudio, Source `scripts/run-tests.R`, then call:

```r
run_tests("examples/sum.R")
```

or from a terminal / VSCode:

```bash
Rscript scripts/run-tests.R examples/sum.R
```

Passing tests show `✓`; each failure shows the byte counts, a line-by-line diff
(expected vs. actual), the exit status, and any error output. When the outputs
differ only in something invisible — a trailing newline, trailing whitespace, or
CRLF vs LF — it says so explicitly. Run non-interactively it exits non-zero if
anything fails, so it drops straight into CI.

---

## What's in this folder

```text
r-skeleton-project/
├── README.md              ← you are here
├── r-skeleton-project.Rproj           ← open THIS to start (opens the project in RStudio)
├── analysis.R             ← the main script: the actual analysis
├── R/
│   ├── stats.R            ← reusable helper functions used by analysis.R
│   └── plotting.R         ← helper that shows plots or saves them as PNGs
├── scripts/               ← click-and-run helpers (see table above)
│   ├── get-packages.R
│   ├── run-analysis.R
│   ├── save-packages.R
│   ├── check-packages.R
│   └── run-tests.R        ← run a stdin→stdout script against tests/ (see "Testing")
├── examples/              ← a sample stdin→stdout script (sum.R) for the test runner
├── tests/                 ← test cases: tests/<script-name>/input.X + output.X
├── configure-rstudio.sh   ← one-time RStudio setup (Part 1.2)
├── setup-vscode.sh        ← one-time VSCode setup (Part 1.3)
├── new-project.sh         ← make a fresh project from this skeleton (see below)
├── .vscode/               ← VSCode settings for this project (travels with it)
├── output/                ← generated results (charts, etc.) — created for you
├── renv.lock              ← the exact list of packages + versions (don't edit by hand)
└── renv/                  ← the private package folder (managed automatically)
```

You'll mainly touch `analysis.R` (to change the analysis) and `R/stats.R`
(to change or add helper functions). The rest mostly takes care of itself.

---

## Starting a new project from this skeleton

When you want to begin a new piece of work, don't copy this folder by hand —
use the included script. In iTerm, from inside this project folder, run:

```bash
./new-project.sh ~/Projects/my-new-project
```

Replace `~/Projects/my-new-project` with wherever you want the new project. The
script:

- copies the skeleton (the scripts, `analysis.R`, helper functions, and the
  package list) into the new folder;
- leaves behind anything that shouldn't be shared between projects — the git
  history and the generated `output/`;
- renames the `.Rproj` and updates this README so they match the new project's
  name;
- starts a brand-new, empty git history for it;
- installs the project's packages for you (the same thing
  `scripts/get-packages.R` does), so the new project is ready to run right away.

Then just open the new project (its `.Rproj` in RStudio, or the folder in VSCode)
and run `scripts/run-analysis.R` — no separate install step needed.

> **Notes**
>
> - On a Mac, if the `rsync` tool it needs is missing, the script installs it
>   for you with Homebrew. (You already have it, so this won't come up.)
> - The package install needs the internet and takes a minute or two. To skip it
>   (e.g. you're offline), put `SKIP_PACKAGE_INSTALL=1` in front of the command:
>   `SKIP_PACKAGE_INSTALL=1 ./new-project.sh ~/Projects/my-new-project`. You can
>   install the packages later by Sourcing `scripts/get-packages.R`.

---

## If something looks wrong

- **"could not find function" or a package error when running the analysis** →
  Run `scripts/get-packages.R` (Source it in RStudio, or `Rscript
  scripts/get-packages.R` in VSCode). You probably haven't installed the packages
  on this computer yet.
- **Not sure what state things are in** → Run `scripts/check-packages.R` the same
  way; it tells you plainly what (if anything) is out of sync and which helper
  script to run next.
- **Paths / "file not found" errors** → Make sure you opened the *project*, not a
  lone file: in RStudio open `r-skeleton-project.Rproj` (Part 2.1); in VSCode open the project
  *folder* (Part 3.1). The project relies on knowing its own folder.

---

For a deeper explanation of R's concepts (sessions, workspaces, packages, and
how this all maps to Python/Go/C), see `R-notes.md`.
