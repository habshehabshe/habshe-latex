;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "demo"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("habshe-notes" "")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "habshe-notes"))
 :latex)

