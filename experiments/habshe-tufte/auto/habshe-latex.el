;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "habshe-latex"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "")))
   (TeX-run-style-hooks
    "geometry")
   (TeX-add-symbols
    "fullwidth"
    "tufte"
    "title"
    "heading"
    "subheading"
    "subsubheading"
    "subsubsubheading")
   (LaTeX-add-environments
    '("subtopic" LaTeX-env-args ["argument"] 0)
    '("topic" LaTeX-env-args ["argument"] 0)))
 :latex)

