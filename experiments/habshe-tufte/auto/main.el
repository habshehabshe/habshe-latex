;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "main"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "") ("habshe-tufte" "" "leading=12pt" "topic-scale=1" "subtopic-scale=0.75" "leading=14pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "") ("lipsum" "") ("amsmath" "") ("amssymb" "") ("amsfonts" "")))
   (TeX-run-style-hooks
    "latex2e"
    "habshe-tufte"
    "habshe-tufte10"
    "lipsum"
    "amsmath"
    "amssymb"
    "amsfonts")
   (LaTeX-add-environments
    '("subtopic" LaTeX-env-args ["argument"] 0)
    '("topic" LaTeX-env-args ["argument"] 0)))
 :latex)

