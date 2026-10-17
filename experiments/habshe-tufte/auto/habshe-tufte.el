;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "habshe-tufte"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("pdftexcmds" "") ("geometry" "")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "geometry")
   (TeX-add-symbols
    "fullwidth"
    "tufte"
    "l"
    "subject"
    "heading"
    "subheading"
    "subsubheading"
    "subsubsubheading"
    "habshe"
    "subjectmark"
    "headingmark"
    "subheadingmark"
    "subsubheadingmark"
    "subsubsubheadingmark")
   (LaTeX-add-environments
    '("subtopic" LaTeX-env-args ["argument"] 0)
    '("topic" LaTeX-env-args ["argument"] 0))
   (LaTeX-add-counters
    "subject"
    "heading"
    "subheading"
    "subsubheading"
    "subsubsubheading"))
 :latex)

