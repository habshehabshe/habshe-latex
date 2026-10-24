# POLICY — modules, development, and promotion

## Terms
- **Module**: any `.cls`/`.sty` we ship. `packages/` holds the shipped (stable)
modules. Experiments and showcases are documents at `<category>/<name>/main.tex`.
- This suite is not a TeX Live distribution; "shipping" = the files in `packages/`,
distributed as-is.

## The shadow rule (how files resolve)
TEXINPUTS is `.` then `packages//` then the system tree. A document's own
directory wins for any module name it contains; otherwise the shipped copy
is used. All development flows from this one rule — no build configuration
ever changes based on where a module "currently" lives.

## Development
1. New modules (and WIP edits to shipped ones) live in the experiment directory
testing them, alongside its `main.tex`.
2. All other documents keep seeing the stable version — multi-version
coexistence is free; do not version filenames.
3. To test a shipped class against a WIP module (or vice versa), shadow only
the file under development locally. Mixing is per-file and automatic.
4. A WIP module needed by several experiments at once goes into `packages/`
on a git branch. Never duplicate a module name in two places.

## Promotion (when a module is stable)
1. It compiles using only `packages/` + the experiment's local files.
2. `git mv` it to `packages/` — never copy; the move removes the shadow and
installs the tested bytes atomically.
3. Run `make`. The donor experiment now exercises the shipped copy.
4. Breaking change: update `showcase/` documents in the same commit, then tag.

## Invariants
- Exactly one copy of any module name exists in the tree at any moment.
- `showcase/` documents never shadow modules — they test what is shipped.
- Suspicious staleness: run `kpsewhich <module>` in the document directory
to see which copy is winning.
- Experiments are disposable; `packages/` is the only thing with
backwards-compatibility intent.
