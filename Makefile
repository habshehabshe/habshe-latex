# ==========================================================================
# habshe — build system
#
# Division of labor:
#   * make     discovers documents, provides targets, ships artifacts.
#   * latexmk  decides freshness (via .fdb_latexmk) and drives the engine.
#   * latexmkrc (repo root) is the single toolchain config: LuaLaTeX,
#     nonstopmode, SyncTeX, cleaning policy.
#
# Conventions (load-bearing):
#   * Every document lives at <category>/<name>/main.tex.
#   * Each document dir symlinks latexmkrc -> ../../latexmkrc so that
#     latexmk runs started there (editor-driven) see the same config.
#   * TEXINPUTS puts '.' first: local files shadow packages/.
#   * Promotion = git mv into packages/, never a copy.
# ==========================================================================

LATEXMK       := latexmk
LATEXMK_FLAGS := -cd
ROOT_DIR      := $(CURDIR)

export TEXINPUTS := .:$(ROOT_DIR)/packages//:

EXPERIMENT_SRCS := $(wildcard experiments/*/main.tex)
SHOWCASE_SRCS   := $(wildcard showcase/*/main.tex)
ALL_SRCS        := $(EXPERIMENT_SRCS) $(SHOWCASE_SRCS)
ALL_PDFS        := $(ALL_SRCS:.tex=.pdf)

.DEFAULT_GOAL := all
.PHONY: all experiments showcase watch new dist clean distclean list FORCE

all: experiments showcase

experiments: $(EXPERIMENT_SRCS:.tex=.pdf)
showcase:   $(SHOWCASE_SRCS:.tex=.pdf)

# FORCE defeats make's up-to-date check: make cannot see .cls/.sty/.bib
# dependencies; latexmk can. latexmk no-ops in about a second when fresh.
%.pdf: %.tex FORCE
	$(LATEXMK) $(LATEXMK_FLAGS) $<

# Live preview:  make watch e=habshe-tufte
watch:
	@test -n "$(e)" || { echo 'usage: make watch e=<experiment-name>'; exit 2; }
	@test -f experiments/$(e)/main.tex || { echo 'no such experiment: $(e)'; exit 1; }
	$(LATEXMK) $(LATEXMK_FLAGS) -pvc experiments/$(e)/main.tex

# Scaffold a new experiment (template + rc symlink):  make new e=my-idea
new:
	@test -n "$(e)" || { echo 'usage: make new e=<experiment-name>'; exit 2; }
	@test ! -e experiments/$(e) || { echo 'experiments/$(e) already exists'; exit 1; }
	@mkdir -p experiments/$(e)
	@cp templates/main.tex experiments/$(e)/main.tex
	@ln -s ../../latexmkrc experiments/$(e)/latexmkrc
	@echo 'created experiments/$(e) — build with: make watch e=$(e)'

# Ship: tarball of all PDFs. SyncTeX deliberately excluded (see README).
dist: all
	@test -n "$(ALL_PDFS)" || { echo 'nothing to ship'; exit 1; }
	@tar -czf habshe-pdfs-$$(date +%Y%m%d).tar.gz $(ALL_PDFS)
	@echo 'shipped: habshe-pdfs-$$(date +%Y%m%d).tar.gz'

# -c: auxiliaries only (PDF + synctex.gz survive — see latexmkrc).
clean:
	@set -e; for src in $(ALL_SRCS); do $(LATEXMK) $(LATEXMK_FLAGS) -c $$src; done

# -C: full wipe, including PDFs and synctex.
distclean:
	@set -e; for src in $(ALL_SRCS); do $(LATEXMK) $(LATEXMK_FLAGS) -C $$src; done

list:
	@printf '%s\n' $(ALL_SRCS)
