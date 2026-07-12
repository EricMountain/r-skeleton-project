# How to Use This Project

This is a small, self-contained R project. It's set up so that it "just works"
the same way on any computer, with as few surprises as possible.

You don't need to understand R deeply to use it. If you've written a little
Python in school, you already know enough. Follow the steps in order.

There are two parts below:

1. **One-time setup** — install R and RStudio and configure them. Do this once
   per computer.
2. **Using the project** — open it and run things. Do this every time.

---

## Part 1 · One-time setup (Mac)

These steps assume you're on a Mac and already have **Homebrew** (`brew`),
**iTerm** (a terminal app), and **jq** installed. Everything below is typed into
iTerm. To run a command, copy the line, paste it into iTerm, and press Return.

### 1.1 Install R and RStudio

R is the language. RStudio is the friendly app you'll actually work in (think of
it like a nicer, R-specific version of an editor).

```bash
brew install r rstudio
```

Check it worked:

```bash
R --version
```

You should see something like `R version 4.6.1`. If so, you're good.

### 1.2 Make R start clean every time (important)

By default, R tries to "remember" your leftover data between sessions. This
sounds helpful but causes confusing bugs, because a script can behave
differently depending on invisible junk left over from last time. We turn that
off so every run starts fresh — the way Python does.

Open RStudio, then open the settings: menu bar → **RStudio → Settings…** (or
press `Cmd+,`). This window has a list of tabs down the left side. Make these
changes, then click **OK** (or **Apply**) at the end.

**In the `General` tab** (the important ones):

1. **Uncheck** "Restore .RData into workspace at startup".
2. Set "Save workspace to .RData on exit" to **Never**.
3. **Uncheck** "Show splash screen at startup" — skips the RStudio logo screen so
   it opens straight to your work.

### 1.2b A few comfort settings (optional but nice)

While you're in the same **Settings…** window, these make day-to-day work
easier:

- **Rainbow parentheses** — in the **`Code`** tab, open its **`Display`**
  sub-tab and check **"Rainbow parentheses"**. It colours each level of nested
  `(` `)` `[` `]` `{` `}` differently, so it's easy to see which bracket matches
  which — handy in R, where function calls nest a lot.
- **Put the Console in the top-right** — open the **`Pane Layout`** tab. RStudio's
  window is four panes; here you choose what goes where. Set the **top-right**
  pane to **Console**. That puts your code editor (top-left) and the Console
  right next to each other, which is a comfortable side-by-side setup.

Click **OK** when done.

### 1.3 Tell RStudio where Git is

> Quit RStudio before running this (RStudio rewrites that file when it closes,
> which would undo the change). Reopen it afterward.

RStudio needs to know where the `git` program lives on your computer. Run this
**one-liner** in iTerm. It finds `git` automatically and writes the path into
RStudio's settings:

```bash
f=~/.config/rstudio/rstudio-prefs.json; mkdir -p "${f%/*}"; [ -s "$f" ] || echo '{}' >"$f"; jq --arg p "$(command -v git)" '.git_exe_path=$p' "$f" >"$f.tmp" && mv "$f.tmp" "$f"
```

The reason for this 1-liner is the rstudio configuration UI resolves the brew git
link to a specific version of git - this setting will break when git is upgraded.

---

## Part 2 · Using the project

### 2.1 Open the project

Always open the project via the `.Rproj` file, not by opening individual files —
this makes sure everything points at the right place.

#### In Finder

Navigate to the directory containing the project, then open the `.RProj` file.

#### In iTerm

```bash
open ~/Projects/R-test/R-test.Rproj
```

This opens the folder **as a project** in RStudio.

### 2.2 First time only: get the packages

A "package" is a bundle of extra R functions someone else wrote (like a Python
library you'd `pip install`). This project lists exactly which packages and
which versions it needs, in a file called `renv.lock`. You install them all in
one step:

1. In RStudio's **Files** panel (bottom-right), click into the `scripts` folder.
2. Open **`get-packages.R`**.
3. Click the **Source** button at the top-right of the editor (or press
   `Cmd+Shift+S`).

Wait for it to finish. When you see `✅ All packages are installed`, you're done.
The packages install into a private folder *inside this project*, so they can't
clash with anything else on your computer.

### 2.3 Run the analysis

1. Open **`scripts/run-analysis.R`**.
2. Click **Source** (or `Cmd+Shift+S`).

You'll see numbers printed in the **Console** (bottom-left), and a chart appears
in the **Plots** pane (bottom-right). That's it.

> **Saving a chart to a file.** In RStudio, charts show in the Plots pane and
> aren't written to disk. To also save them as PNG files in the `output` folder,
> type `Sys.setenv(SAVE_PLOTS = 1)` in the Console once, then Source the script
> again. (When the project is run non-interactively with `Rscript`, charts are
> always saved, since there's no Plots pane to draw on.)

> **Why "Source" and not just running lines?** *Source* runs the whole file from
> top to bottom in one go, the way a finished script is meant to run. You can
> also step through a file line by line with `Cmd+Return` while you're
> experimenting — but for running the finished thing, use Source.

---

## The helper scripts

Everything you routinely need is a file in the `scripts/` folder. Open one and
click **Source**. You never have to memorize commands.

| Open this file            | What it does                                             | When to use it                                  |
| ------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| `scripts/get-packages.R`  | Installs all packages the project needs                  | Once, the first time you open the project       |
| `scripts/run-analysis.R`  | Runs the main analysis and shows results                 | Any time you want to see the output             |
| `scripts/save-packages.R` | Records a package you just added into `renv.lock`        | After you add a new `library(...)` to your code |
| `scripts/check-packages.R`| Reports whether your packages match the project list     | Any time you're unsure things are in sync       |

### Adding a new package

Say you want to use a package called `janitor`. Two steps:

1. In the RStudio **Console** (bottom-left), type and press Return:
   ```r
   renv::install("janitor")
   ```
2. Add `library(janitor)` to your script where you use it, then open
   `scripts/save-packages.R` and **Source** it to record the new package.

---

## What's in this folder

```
R-test/
├── README.md              ← you are here
├── R-test.Rproj           ← open THIS to start (opens the project in RStudio)
├── analysis.R             ← the main script: the actual analysis
├── R/
│   └── stats.R            ← reusable helper functions used by analysis.R
├── scripts/               ← click-and-run helpers (see table above)
│   ├── get-packages.R
│   ├── run-analysis.R
│   ├── save-packages.R
│   └── check-packages.R
├── new-project.sh         ← make a fresh project from this skeleton (see below)
├── output/                ← generated results (charts, etc.) — created for you
├── renv.lock              ← the exact list of packages + versions (don't edit by hand)
└── renv/                  ← the private package folder (managed automatically)
```

You'll mainly touch **`analysis.R`** (to change the analysis) and **`R/stats.R`**
(to change or add helper functions). The rest mostly takes care of itself.

---

## Starting a new project from this skeleton

When you want to begin a *new* piece of work, don't copy this folder by hand —
use the included script. In **iTerm**, from inside this project folder, run:

```bash
./new-project.sh ~/Projects/my-new-project
```

Replace `~/Projects/my-new-project` with wherever you want the new project. The
script:

- copies the skeleton (the scripts, `analysis.R`, helper functions, and the
  package list) into the new folder;
- **leaves behind** anything that shouldn't be shared between projects — the git
  history and the generated `output/`;
- renames the `.Rproj` and updates this README so they match the new project's
  name;
- starts a brand-new, empty git history for it;
- **installs the project's packages for you** (the same thing
  `scripts/get-packages.R` does), so the new project is ready to run right away.

Then just open the new project's `.Rproj` and Source `scripts/run-analysis.R` —
no separate install step needed.

> **Notes**
> - On a Mac, if the `rsync` tool it needs is missing, the script installs it
>   for you with Homebrew. (You already have it, so this won't come up.)
> - The package install needs the internet and takes a minute or two. To skip it
>   (e.g. you're offline), put `SKIP_PACKAGE_INSTALL=1` in front of the command:
>   `SKIP_PACKAGE_INSTALL=1 ./new-project.sh ~/Projects/my-new-project`. You can
>   install the packages later by Sourcing `scripts/get-packages.R`.

---

## If something looks wrong

- **"could not find function" or a package error when running the analysis** →
  Open `scripts/get-packages.R` and Source it. You probably haven't installed
  the packages on this computer yet.
- **Not sure what state things are in** → Open `scripts/check-packages.R` and
  Source it; it tells you plainly what (if anything) is out of sync and which
  helper script to run next.
- **Paths / "file not found" errors** → Make sure you opened the project via
  `R-test.Rproj` (Part 2.1), not by opening a lone file. The project relies on
  knowing its own folder.

---

*For a deeper explanation of R's concepts (sessions, workspaces, packages, and
how this all maps to Python/Go/C), see `R-notes.md`.*
