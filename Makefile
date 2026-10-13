# Find all top-level main.tex documents in experiments/ and showcase/
EXPERIMENT_SRCS := $(wildcard experiments/*/main.tex)
SHOWCASE_SRCS   := $(wildcard showcase/*/main.tex)
ALL_SRCS        := $(EXPERIMENT_SRCS) $(SHOWCASE_SRCS)

EXPERIMENT_PDFS := $(EXPERIMENT_SRCS:.tex=.pdf)
SHOWCASE_PDFS   := $(SHOWCASE_SRCS:.tex=.pdf)
ALL_PDFS        := $(ALL_SRCS:.tex=.pdf)

# Export packages/ to TEXINPUTS so any subfolder document can do \usepackage{habshe-notes}
ROOT_DIR        := $(shell pwd)
export TEXINPUTS := $(ROOT_DIR)/packages//:

.PHONY: all experiments showcase clean distclean

all: experiments showcase

experiments: $(EXPERIMENT_PDFS)
showcase: $(SHOWCASE_PDFS)

# -cd changes into the document directory before building
%.pdf: %.tex
	latexmk -cd $<

# Clean aux files, keep PDFs and SyncTeX
clean:
	@for src in $(ALL_SRCS); do \
		latexmk -cd -c $$src; \
	done

# Full wipe: remove PDFs, SyncTeX, and all aux files
distclean:
	@for src in $(ALL_SRCS); do \
		latexmk -cd -C $$src; \
	done
