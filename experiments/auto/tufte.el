;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "tufte"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("tufte-handout" "")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("graphicx" "") ("units" "") ("multicol" "") ("fancyvrb" "") ("amsmath" "") ("amssymb" "") ("booktabs" "") ("lipsum" "")))
   (TeX-run-style-hooks
    "latex2e"
    "tufte-handout"
    "tufte-handout10"
    "amsmath"
    "amssymb"
    "booktabs"
    "lipsum")
   (TeX-add-symbols
    '("imageplaceholder" ["argument"] 1)
    '("reference" 1)
    '("attribution" 1)
    '("textsc" 1)
    '("smallcaps" 1)
    '("allcaps" 1)
    "suppresscaptionlabel")
   (LaTeX-add-labels
    "fig:margin-sample"
    "tab:margin-sample"
    "fig:body-sample"
    "tab:body-sample"
    "fig:full-sample"
    "tab:full-sample")
   (LaTeX-add-environments
    '("Mlisting" LaTeX-env-args ["Text"])
    '("Blisting" LaTeX-env-args ["Text"])
    '("Flisting" LaTeX-env-args ["Text"])
    '("Fquote")
    '("Bquote")
    '("Mquote" LaTeX-env-args ["Text"])
    '("Mmath" LaTeX-env-args ["Text"])
    '("Bmath" LaTeX-env-args ["Text"])
    '("Fmath" LaTeX-env-args ["Text"])
    '("Mnote" LaTeX-env-args ["Text"])
    '("Bnote")
    '("Fnote")
    '("Mtable" LaTeX-env-args ["Text"])
    '("Btable" LaTeX-env-args ["Text"])
    '("Ftable" LaTeX-env-args ["Text"])
    '("Mfigure" LaTeX-env-args ["Text"])
    '("Bfigure" LaTeX-env-args ["Text"])
    '("Ffigure" LaTeX-env-args ["Text"])
    '("@tufte@margin@float" LaTeX-env-args ["argument"] 1))
   (LaTeX-add-bibliographies)
   (LaTeX-add-saveboxes
    "habshequotebox"))
 :latex)

