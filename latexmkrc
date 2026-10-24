# =========================================================================
# habshe — latexmk configuration (single source of truth for the toolchain)
#
# latexmk reads rc files at STARTUP: system -> user (~/.latexmkrc) ->
# current directory. So this file applies when latexmk is invoked from the
# repo root (i.e., via make). Each document directory carries a symlink
# `latexmkrc -> ../../latexmkrc` so editor-driven runs see this same file.
# Debugging: latexmk lists the rc files it read at startup (-rc-report).
# =========================================================================

# --- Engine: LuaLaTeX, direct to PDF --------------------------------------
$pdf_mode = 4;

# --- Run behavior ----------------------------------------------------------
# Never pause for terminal input: make and CI must fail loudly, not hang.
# %O = options latexmk injects, %S = source file.
$lualatex = 'lualatex -interaction=nonstopmode -synctex=1 %O %S';

# --- Bibliography -----------------------------------------------------------
# Nothing to configure. Default $bibtex_use = 1: latexmk auto-detects
# biblatex (.bcf -> biber) vs. bibtex and reruns whenever citations change,
# since the .bib file exists. ($biber's default string is already 'biber %O %S'.)

# --- Cleaning -----------------------------------------------------------------
# The built-in -c set is small: .log .aux .fdb_latexmk plus
# @generated_exts = (aux bbl idx ind lof lot out toc fdb_latexmk).
# NOT cleaned by default: .fls .blg .bcf .run.xml .ilg .synctex.gz
# -> the additions below are load-bearing, not redundant.

# -c: auxiliaries only; the PDF and synctex.gz SURVIVE (editor round-trip
# stays intact). 'bbl' deliberately overrides the default "bbl is precious"
# rule: our .bib is always present, so a cleaned .bbl is simply regenerated.
$clean_ext = 'bbl blg fls bcf run.xml ilg nav snm vrb tdo';

# -C: additionally the PDF and the synctex data. (The busy marker's real
# name is <job>.synctex.gz(busy) for compressed synctex.)
$clean_full_ext = 'synctex.gz synctex.gz(busy)';

# --- Preview (used by `make watch` / latexmk -pvc) ---------------------------
$pdf_previewer = 'start okular --unique %O %S';
