%% 
%% habshe-tufte.cls
%% A Tufte-inspired notes class built on article.cls with geometry integration.
%% Version 0.8 (2026-10-24)
%% 
%% --------------------------------------------------------------------
%% FILE INDEX (manually maintained)
%% 
%% §1  Class options & delegation .... keys, parsing, article load
%% §2  Calculation engine ............ all formulas (pure, no state)
%% §3  Typography .................... scale registers, NFSS, math sizes
%% §4  Page geometry ................. measures, partition, geometry, guards
%% §5  Layout streams ................ state machine, margin guard
%% §6  Sectioning .................... counters, TOC hooks, headings
%% §7  Structural environments ........ topic / subtopic
%% §8  Baseline application .......... single place globals are assigned
%% §9  Runtime init .................. begin-document, log matrix dump
%% 
%% SECTION CONVENTIONS: every section banner carries Purpose / Owns /
%% Depends / Affects / Notes. Registers are declared in the section
%% that owns them; no forward references between sections.
%% --------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{habshe-tufte}[2026-10-24 v0.8 Geometric Proportional Notes Class]

% fix-cm: LOAD-BEARING. The scale below produces sizes CM was never cut
% at (e.g. 9.98pt); fix-cm swaps in fully-scalable metric files so
% arbitrary \fontsize values render correctly. Without it you get
% nearest-design-size substitution ("fonts looked weird").
% NOTE: the 0.5 char-width factor in §4 is a CM-metrics calibration;
% ANY font change (lmodern, fontspec) requires re-measuring it.
\RequirePackage{fix-cm}
% (xfp dropped: the 2022-06-01 format floor provides \fpeval natively.)

% ==================================================================
% §1  CLASS OPTIONS & DELEGATION
% ------------------------------------------------------------------
% Purpose: Declare and process the class keys; normalize raw user
% input (parsing layer); forward unknown options to article;
% load article with the normalized papersize.
% Owns:    \habshe@papersize@raw, \habshe@papersize,
% \habshe@fontsize@raw, \habshe@fontsize@d
% Depends: nothing above (article for delegation).
% Affects: article's option list; \paperwidth/\paperheight (via the
% papersize option executed inside article).
% Notes:   Two layers live here and ONLY here: key declarations and
% input normalization (string surgery). All arithmetic is
% §2's job. fontsize accepts "9" and "9pt" (pt only).
% ==================================================================

\DeclareKeys{
  papersize .store = \habshe@papersize@raw,
  fontsize  .code = {\habshe@set@fontsize{#1}},
}

% Unknown options: warn if it's a standard size option (which this
% class deliberately ignores), then forward to article regardless so
% that global options are consumed exactly once.
\newcommand{\habshe@warn@size@option}[1]{%
  \def\habshe@tmp{#1}%
  \def\habshe@@tmp{10pt}\ifx\habshe@tmp\habshe@@tmp \habshe@size@opt@warn \fi
  \def\habshe@@tmp{11pt}\ifx\habshe@tmp\habshe@@tmp \habshe@size@opt@warn \fi
  \def\habshe@@tmp{12pt}\ifx\habshe@tmp\habshe@@tmp \habshe@size@opt@warn \fi
}
\newcommand{\habshe@size@opt@warn}{%
  \ClassWarning{habshe-tufte}{%
    Standard size option has no effect on this class:\MessageBreak
    all sizes derive from the class's own scale.\MessageBreak
    Use 'fontsize=<size>pt' instead (pt only)%
  }%
}
\DeclareUnknownKeyHandler{%
  \habshe@warn@size@option{\CurrentOption}%
  \PassOptionsToClass{\CurrentOption}{article}%
}

% ---- Parsing layer: fontsize -------------------------------------
% House idiom (same as the papersize normalizer below): append the
% unit, then split at the first "pt" delimiter. Accepts "9" and "9pt".
% Garbage fails naturally when \setlength rejects the result.
\newcommand{\habshe@set@fontsize}[1]{%
  \expandafter\habshe@@set@fontsize#1pt\@nil}
\def\habshe@@set@fontsize#1pt#2\@nil{%
  \def\habshe@fontsize@raw{#1pt}}

% ---- Defaults ----------------------------------------------------
\def\habshe@papersize@raw{a4}
\habshe@set@fontsize{9pt}

\ProcessKeyOptions\relax

% ---- Parsing layer: papersize ------------------------------------
% Accepts both "a4" and "a4paper"; yields the article/geometry form.
\def\habshe@strip@paper#1paper#2\@nil{#1paper}
\edef\habshe@papersize{%
  \expandafter\habshe@strip@paper\habshe@papersize@raw paper\@nil}

% ---- Seed register + sanity guard --------------------------------
\newdimen\habshe@fontsize@d
\setlength\habshe@fontsize@d{\habshe@fontsize@raw}
\ifdim\habshe@fontsize@d<4pt
  \ClassError{habshe-tufte}{%
    fontsize \habshe@fontsize@raw\space is too small%
  }{%
    The scale is calibrated for body sizes of at least 4pt.\MessageBreak
    Smaller values collapse the 16-tier ladder.%
  }%
\fi

% ---- Delegate to article ------------------------------------------
% MUST precede \LoadClass: article's paper options set \paperwidth /
% \paperheight, which §4 consumes. Must precede §2+: our definitions
% override whatever size .clo article loads.
\PassOptionsToClass{\habshe@papersize}{article}
\LoadClass{article}

% ==================================================================
% §2  CALCULATION ENGINE
% ------------------------------------------------------------------
% Purpose: Every formula in the class, in one place. Pure: no state,
% no LaTeX parameters are assigned here — macros expand to
% "<number>pt" strings or glue for consumers in §3-§8.
% Owns:    All formula parameters; \habshe@calc@size,
% \habshe@calc@leading, \habshe@glue.
% Depends: §1 (\habshe@fontsize@d).
% Affects: nothing directly; everything in §3-§8 through these macros.
% Notes:   ALL arithmetic goes through \fpeval — even coefficient
% \fpeval ALWAYS expands to a bare decimal (fp_to_decimal):
% never a unit. The caller appends the unit AFTER the closing
% brace. Inside an fp expression, "pt" is a CONSTANT equal to
% 1 (juxtaposition multiplication): "\fpeval{(...) pt}"
% silently multiplies by 1 and emits a unitless number.
% ==================================================================

% ------------------------------------------------------------------
% 2.1  Typographic scale
% 
% S(k) = F*exp(g*(k - a)) - k/d + l*max(0,k)^2 + o
% 
% F  seed size (the fontsize option)     g  growth rate
% a  anchor step                         d  damper divisor
% l  quadratic lift coefficient          o  static offset (pt)
% 
% SEED SEMANTICS: the fontsize option is the SEED of the scale —
% the canonical character unit of the system — and names the
% \regular tier exactly: a = 2, o = -0.35, so S(2) = F
% identically. It is NOT a promise about the rendered size of
% anything: placement follows the reserved-range conventions
% (§3: ambient body = SMALL ≈ 0.93F; §4: measures from range
% medians), which are independent of the anchor.
% 
% SLOPE BEHAVIOR (verified, deliberate — do not "fix" the damper
% sign): the -k/d term contributes a constant -1/d to the slope,
% flattening the ladder below the anchor; the lift term +2*l*k
% steepens it above. Steeper above, shallower below, as intended.
% 
% Illustrative ladder at F = 9pt (the AUTHORITATIVE record is
% the ClassInfo matrix dump in §9, printed every run):
% HUGE 21.95, Huge 18.90, huge 16.21, LARGE 13.88, Large 11.90,
% large 10.28, regular 9.00, SMALL 8.07, Small 7.47, small 7.07,
% TINY 6.70, Tiny 6.37, tiny 6.06, MINUSCULE 5.79,
% Minuscule 5.54, minuscule 5.32.
% Strictly monotonic for k in [-7, 8] at these parameters.
% ------------------------------------------------------------------
\newcommand{\habshe@scale@growth}{0.07}   % g
\newcommand{\habshe@scale@anchor}{2}      % a  (regular = seed tier)
\newcommand{\habshe@scale@damper}{8}      % d
\newcommand{\habshe@scale@lift}{0.15}     % l
\newcommand{\habshe@scale@offset}{-0.35}  % o  (so S(2) = F exactly)

\newcommand{\habshe@calc@size}[1]{%
  \fpeval{%
    ( \habshe@fontsize@d * exp(\habshe@scale@growth * ((#1) - \habshe@scale@anchor))
    - ((#1) / \habshe@scale@damper)
    + (\habshe@scale@lift * (max(0, #1)^2))
    + \habshe@scale@offset
    )
  }pt%
}


% ------------------------------------------------------------------
% 2.2  Leading
% 
% L(S, k) = S * r - k/d' + o'
% 
% r  ratio     d' damper     o' offset
% d' and o' are INERT (r-only leading for v0.8); they are the
% reserved v0.9 extension point for size-dependent leading —
% do not delete, wire them when the leading formula matures.
% ------------------------------------------------------------------
\newcommand{\habshe@lead@ratio}{1.20}
\newcommand{\habshe@lead@damper}{999999}  % inert until v0.9
\newcommand{\habshe@lead@offset}{0}       % inert until v0.9

% #1 = size dimension register, #2 = step index k
\newcommand{\habshe@calc@leading}[2]{%
  \fpeval{%
    ( (#1) * \habshe@lead@ratio
    - ((#2) / \habshe@lead@damper)
    + \habshe@lead@offset
    )
  }pt%
}


% ------------------------------------------------------------------
% 2.3  Glue builder
% 
% \habshe@glue{base}{natural}{plus}{minus}
% -> natural*base pt  plus  plus*base pt  minus  minus*base pt
% 
% base is a dimension register; the three coefficients are
% evaluated through \fpeval. Every elastic skip in this class
% is built here, so the three roles are always visible and
% never ambiguous. Sign convention: negative beforeskips carry
% negative stretch (kernel requirement for indent suppression).
% ------------------------------------------------------------------
\newcommand{\habshe@glue}[4]{%
  \glueexpr
  \fpeval{#2 * #1}pt
  plus  \fpeval{#3 * #1}pt
  minus \fpeval{#4 * #1}pt
  \relax
}

% ==================================================================
% §3  TYPOGRAPHY
% ------------------------------------------------------------------
% Purpose: The 16-tier size/leading registers, their NFSS commands,
% the ambient wiring of \normalsize, the math-size table,
% compatibility aliases, and list spacing hooks.
% Owns:    All \habshe@size@*/\habshe@leading@* registers, \habshe@num@*
% strings, \habshe@leading@d, display-skip registers,
% list-skip registers, \@listi/\@listii.
% Depends: §2 (\habshe@calc@size, \habshe@calc@leading, \habshe@glue).
% Affects: \normalsize and all tier switches; \DeclareMathSizes table;
% \abovedisplayskip family (via \normalsize); list spacing.
% Notes:   AMBIENT SIZE: \normalsize IS the SMALL tier (one tier below
% \regular). \regular is a distinct pure tier switch and no
% longer \let to \normalsize. Only \normalsize sets display
% skips and resets \@listi (kernel convention); the pure
% tier switches change font metrics only.
% ==================================================================

% ---- Size and leading registers ----------------------------------
\newdimen\habshe@size@HUGE@d
\newdimen\habshe@size@Huge@d
\newdimen\habshe@size@huge@d
\newdimen\habshe@size@LARGE@d
\newdimen\habshe@size@Large@d
\newdimen\habshe@size@large@d
\newdimen\habshe@size@regular@d
\newdimen\habshe@size@SMALL@d
\newdimen\habshe@size@Small@d
\newdimen\habshe@size@small@d
\newdimen\habshe@size@TINY@d
\newdimen\habshe@size@Tiny@d
\newdimen\habshe@size@tiny@d
\newdimen\habshe@size@MINUSCULE@d
\newdimen\habshe@size@Minuscule@d
\newdimen\habshe@size@minuscule@d

\newdimen\habshe@leading@HUGE@d
\newdimen\habshe@leading@Huge@d
\newdimen\habshe@leading@huge@d
\newdimen\habshe@leading@LARGE@d
\newdimen\habshe@leading@Large@d
\newdimen\habshe@leading@large@d
\newdimen\habshe@leading@regular@d
\newdimen\habshe@leading@SMALL@d
\newdimen\habshe@leading@Small@d
\newdimen\habshe@leading@small@d
\newdimen\habshe@leading@TINY@d
\newdimen\habshe@leading@Tiny@d
\newdimen\habshe@leading@tiny@d
\newdimen\habshe@leading@MINUSCULE@d
\newdimen\habshe@leading@Minuscule@d
\newdimen\habshe@leading@minuscule@d

\setlength\habshe@size@HUGE@d      {\habshe@calc@size{8}}
\setlength\habshe@size@Huge@d      {\habshe@calc@size{7}}
\setlength\habshe@size@huge@d      {\habshe@calc@size{6}}
\setlength\habshe@size@LARGE@d     {\habshe@calc@size{5}}
\setlength\habshe@size@Large@d     {\habshe@calc@size{4}}
\setlength\habshe@size@large@d     {\habshe@calc@size{3}}
\setlength\habshe@size@regular@d   {\habshe@calc@size{2}}
\setlength\habshe@size@SMALL@d      {\habshe@calc@size{1}}
\setlength\habshe@size@Small@d      {\habshe@calc@size{0}}
\setlength\habshe@size@small@d      {\habshe@calc@size{-1}}
\setlength\habshe@size@TINY@d       {\habshe@calc@size{-2}}
\setlength\habshe@size@Tiny@d       {\habshe@calc@size{-3}}
\setlength\habshe@size@tiny@d       {\habshe@calc@size{-4}}
\setlength\habshe@size@MINUSCULE@d  {\habshe@calc@size{-5}}
\setlength\habshe@size@Minuscule@d  {\habshe@calc@size{-6}}
\setlength\habshe@size@minuscule@d  {\habshe@calc@size{-7}}

\setlength\habshe@leading@HUGE@d     {\habshe@calc@leading{\habshe@size@HUGE@d}{8}}
\setlength\habshe@leading@Huge@d     {\habshe@calc@leading{\habshe@size@Huge@d}{7}}
\setlength\habshe@leading@huge@d     {\habshe@calc@leading{\habshe@size@huge@d}{6}}
\setlength\habshe@leading@LARGE@d    {\habshe@calc@leading{\habshe@size@LARGE@d}{5}}
\setlength\habshe@leading@Large@d    {\habshe@calc@leading{\habshe@size@Large@d}{4}}
\setlength\habshe@leading@large@d    {\habshe@calc@leading{\habshe@size@large@d}{3}}
\setlength\habshe@leading@regular@d  {\habshe@calc@leading{\habshe@size@regular@d}{2}}
\setlength\habshe@leading@SMALL@d    {\habshe@calc@leading{\habshe@size@SMALL@d}{1}}
\setlength\habshe@leading@Small@d    {\habshe@calc@leading{\habshe@size@Small@d}{0}}
\setlength\habshe@leading@small@d    {\habshe@calc@leading{\habshe@size@small@d}{-1}}
\setlength\habshe@leading@TINY@d     {\habshe@calc@leading{\habshe@size@TINY@d}{-2}}
\setlength\habshe@leading@Tiny@d     {\habshe@calc@leading{\habshe@size@Tiny@d}{-3}}
\setlength\habshe@leading@tiny@d     {\habshe@calc@leading{\habshe@size@tiny@d}{-4}}
\setlength\habshe@leading@MINUSCULE@d {\habshe@calc@leading{\habshe@size@MINUSCULE@d}{-5}}
\setlength\habshe@leading@Minuscule@d {\habshe@calc@leading{\habshe@size@Minuscule@d}{-6}}
\setlength\habshe@leading@minuscule@d {\habshe@calc@leading{\habshe@size@minuscule@d}{-7}}

% System base leading L: leading of the AMBIENT tier (SMALL).
% Scales the entire vertical canvas in §4 and the elastic skips below.
\newdimen\habshe@leading@d
\setlength\habshe@leading@d{\habshe@leading@SMALL@d}

% ---- Elastic skips derived from L ---------------------------------
\newskip\habshe@displayskip
\newskip\habshe@displayshortskip
\newskip\habshe@belowdisplayshortskip
\newskip\habshe@list@topsep
\newskip\habshe@list@itemsep
\newskip\habshe@list@parsep
\newskip\habshe@list@topsep@ii

\setlength\habshe@displayskip{%
  \habshe@glue{\habshe@leading@d}{1.0}{0.2}{0.1}}
\setlength\habshe@displayshortskip{%
  \habshe@glue{\habshe@leading@d}{0.0}{0.2}{0.0}}
\setlength\habshe@belowdisplayshortskip{%
  \habshe@glue{\habshe@leading@d}{0.5}{0.2}{0.1}}
\setlength\habshe@list@topsep{%
  \habshe@glue{\habshe@leading@d}{0.5}{0.15}{0.1}}
\setlength\habshe@list@itemsep{%
  \habshe@glue{\habshe@leading@d}{0.25}{0.1}{0.0}}
\setlength\habshe@list@parsep{%
  \habshe@glue{\habshe@leading@d}{0.0}{0.05}{0.0}}
\setlength\habshe@list@topsep@ii{%
  \habshe@glue{\habshe@leading@d}{0.25}{0.1}{0.0}}

% ---- List hooks ----------------------------------------------------
% PARKED (S1): \@listiii / \@listiv still inherit article's size .clo
% metrics at nesting depth >= 3. Flesh out in the v0.9 vertical pass.
\def\@listi{%
  \leftmargin\leftmargini
  \parsep\habshe@list@parsep
  \topsep\habshe@list@topsep
  \itemsep\habshe@list@itemsep}
\let\@listI\@listi
\def\@listii{%
  \leftmargin\leftmarginii
  \labelwidth\leftmarginii
  \advance\labelwidth-\labelsep
  \topsep\habshe@list@topsep@ii
  \parsep\z@
  \itemsep\parsep}

% ---- Exact-match strings for NFSS ---------------------------------
\edef\habshe@num@HUGE     {\strip@pt\habshe@size@HUGE@d}
\edef\habshe@num@Huge     {\strip@pt\habshe@size@Huge@d}
\edef\habshe@num@huge     {\strip@pt\habshe@size@huge@d}
\edef\habshe@num@LARGE    {\strip@pt\habshe@size@LARGE@d}
\edef\habshe@num@Large    {\strip@pt\habshe@size@Large@d}
\edef\habshe@num@large    {\strip@pt\habshe@size@large@d}
\edef\habshe@num@regular  {\strip@pt\habshe@size@regular@d}
\edef\habshe@num@SMALL    {\strip@pt\habshe@size@SMALL@d}
\edef\habshe@num@Small    {\strip@pt\habshe@size@Small@d}
\edef\habshe@num@small    {\strip@pt\habshe@size@small@d}
\edef\habshe@num@TINY     {\strip@pt\habshe@size@TINY@d}
\edef\habshe@num@Tiny     {\strip@pt\habshe@size@Tiny@d}
\edef\habshe@num@tiny     {\strip@pt\habshe@size@tiny@d}
\edef\habshe@num@MINUSCULE {\strip@pt\habshe@size@MINUSCULE@d}
\edef\habshe@num@Minuscule {\strip@pt\habshe@size@Minuscule@d}
\edef\habshe@num@minuscule {\strip@pt\habshe@size@minuscule@d}

% ---- Math sizes: script = k-2, scriptscript = k-4 -------------------
% Both sides of each row derive from the same \habshe@num@* strings,
% so \f@size lookups hit the table by construction (no fallback
% ratios, no substitution warnings).
\DeclareMathSizes{\habshe@num@HUGE}     {\habshe@num@HUGE}     {\habshe@num@huge}     {\habshe@num@Large}
\DeclareMathSizes{\habshe@num@Huge}     {\habshe@num@Huge}     {\habshe@num@LARGE}    {\habshe@num@large}
\DeclareMathSizes{\habshe@num@huge}     {\habshe@num@huge}     {\habshe@num@Large}    {\habshe@num@regular}
\DeclareMathSizes{\habshe@num@LARGE}    {\habshe@num@LARGE}    {\habshe@num@large}    {\habshe@num@SMALL}
\DeclareMathSizes{\habshe@num@Large}    {\habshe@num@Large}    {\habshe@num@regular} {\habshe@num@Small}
\DeclareMathSizes{\habshe@num@large}    {\habshe@num@large}    {\habshe@num@SMALL}    {\habshe@num@small}
\DeclareMathSizes{\habshe@num@regular}  {\habshe@num@regular}  {\habshe@num@SMALL}    {\habshe@num@TINY}
\DeclareMathSizes{\habshe@num@SMALL}    {\habshe@num@SMALL}    {\habshe@num@small}    {\habshe@num@Tiny}
\DeclareMathSizes{\habshe@num@Small}    {\habshe@num@Small}    {\habshe@num@TINY}     {\habshe@num@tiny}
\DeclareMathSizes{\habshe@num@small}    {\habshe@num@small}    {\habshe@num@Tiny}     {\habshe@num@MINUSCULE}
\DeclareMathSizes{\habshe@num@TINY}     {\habshe@num@TINY}     {\habshe@num@tiny}     {\habshe@num@Minuscule}
\DeclareMathSizes{\habshe@num@Tiny}     {\habshe@num@Tiny}     {\habshe@num@MINUSCULE}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@tiny}     {\habshe@num@tiny}     {\habshe@num@MINUSCULE}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@MINUSCULE}{\habshe@num@MINUSCULE}{\habshe@num@minuscule}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@Minuscule}{\habshe@num@Minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}

% ---- NFSS tier commands --------------------------------------------
% Pure tier switches: font size + leading only.
\DeclareRobustCommand\HUGE{\@setfontsize\HUGE{\habshe@num@HUGE}{\habshe@leading@HUGE@d}}
\DeclareRobustCommand\Huge{\@setfontsize\Huge{\habshe@num@Huge}{\habshe@leading@Huge@d}}
\DeclareRobustCommand\huge{\@setfontsize\huge{\habshe@num@huge}{\habshe@leading@huge@d}}
\DeclareRobustCommand\LARGE{\@setfontsize\LARGE{\habshe@num@LARGE}{\habshe@leading@LARGE@d}}
\DeclareRobustCommand\Large{\@setfontsize\Large{\habshe@num@Large}{\habshe@leading@Large@d}}
\DeclareRobustCommand\large{\@setfontsize\large{\habshe@num@large}{\habshe@leading@large@d}}
\DeclareRobustCommand\regular{\@setfontsize\regular{\habshe@num@regular}{\habshe@leading@regular@d}}
\DeclareRobustCommand\SMALL{\@setfontsize\SMALL{\habshe@num@SMALL}{\habshe@leading@SMALL@d}}
\DeclareRobustCommand\Small{\@setfontsize\Small{\habshe@num@Small}{\habshe@leading@Small@d}}
\DeclareRobustCommand\small{\@setfontsize\small{\habshe@num@small}{\habshe@leading@small@d}}
\DeclareRobustCommand\TINY{\@setfontsize\TINY{\habshe@num@TINY}{\habshe@leading@TINY@d}}
\DeclareRobustCommand\Tiny{\@setfontsize\Tiny{\habshe@num@Tiny}{\habshe@leading@Tiny@d}}
\DeclareRobustCommand\tiny{\@setfontsize\tiny{\habshe@num@tiny}{\habshe@leading@tiny@d}}
\DeclareRobustCommand\MINUSCULE{\@setfontsize\MINUSCULE{\habshe@num@MINUSCULE}{\habshe@leading@MINUSCULE@d}}
\DeclareRobustCommand\Minuscule{\@setfontsize\Minuscule{\habshe@num@Minuscule}{\habshe@leading@Minuscule@d}}
\DeclareRobustCommand\minuscule{\@setfontsize\minuscule{\habshe@num@minuscule}{\habshe@leading@minuscule@d}}

% ---- The ambient size: \normalsize IS the SMALL tier -----------------
% Kernel conventions kept: \normalsize (and only \normalsize) also sets
% the display skips and restores \@listi. Every font reset in the
% document therefore lands on SMALL — the ambient body size.
\DeclareRobustCommand\normalsize{%
  \@setfontsize\normalsize{\habshe@num@SMALL}{\habshe@leading@SMALL@d}%
  \abovedisplayskip\habshe@displayskip
  \belowdisplayskip\habshe@displayskip
  \abovedisplayshortskip\habshe@displayshortskip
  \belowdisplayshortskip\habshe@belowdisplayshortskip
  \let\@listi\@listI}
\normalsize

% ---- Compatibility aliases ------------------------------------------
% Standard names must exist for external packages. Note the honest
% quirk: \footnotesize (Small) > \small (small) here, inverting the
% standard ordering — accepted; packages use them as "smaller than
% \normalsize", which holds.
\let\footnotesize\Small
\let\scriptsize\TINY

% ==================================================================
% §4  PAGE GEOMETRY
% ------------------------------------------------------------------
% Purpose: Character-based text measures, the horizontal partition,
% the vertical canvas, geometry integration, load-time
% guards, and the margin-note size single source.
% Owns:    All measure/partition/canvas registers; the geometry call;
% \habshe@marginnote@size / \habshe@marginnote@d;
% \@marginparreset; the remainder guard.
% Depends: §1 (\habshe@papersize, \paperwidth via article);
% §2 (\fpeval); §3 (size registers, \habshe@leading@d).
% Affects: \textwidth, \marginparwidth, \marginparsep, all page
% dimensions; margin note formatting.
% Notes:   WIDTH RULES (convention, deliberate): each region's width
% is sized in characters of the MEDIAN of its reserved size
% range — body: {regular..small} -> (SMALL+small)/2;
% margin: {TINY..tiny} -> Tiny. The 0.5 char-width factor
% is a CM-metrics calibration (see header comment).
% ==================================================================

% ---- Margin-note size: SINGLE SOURCE OF TRUTH -----------------------
% "Margin notes run at Tiny" is one decision recorded here, in two
% forms: the NFSS switch (consumed by \@marginparreset) and the dimen
% (consumed by the width formula). Change them together or not at all.
\newcommand{\habshe@marginnote@size}{\Tiny}
\newcommand{\habshe@marginnote@d}{\habshe@size@Tiny@d}

% ---- Measures --------------------------------------------------------
% W_body: 65 characters at the body-range median, half-em wide.
\newdimen\habshe@bodywidth@d
\setlength\habshe@bodywidth@d{%
  \fpeval{65 * 0.5 * ((\habshe@size@SMALL@d + \habshe@size@small@d) / 2)}pt}
% W_margin: 45 characters of the margin-note size, half-em wide.
\newdimen\habshe@marginwidth@d
\setlength\habshe@marginwidth@d{%
  \fpeval{45 * 0.5 * \habshe@marginnote@d}pt}

% ---- Horizontal partition ---------------------------------------------
% X = paperwidth - W_body - W_margin, split 40/20/40 into
% left margin / gutter / right margin. By the algebra of geometry's
% solver (includemp), the derived right margin equals 0.40X, so the
% partition identity holds exactly and \habshe@fullwidth@d below
% equals body + gutter + margin column.
\newdimen\habshe@remainder@X
\setlength\habshe@remainder@X{%
  \fpeval{\paperwidth - \habshe@bodywidth@d - \habshe@marginwidth@d}pt}

% GUARD (S3 rule: no derived quantity without a load-time guard):
% a collapsed remainder means the partition degenerates and geometry
% would emit a silently broken page. Fail loudly instead.
\ifdim\habshe@remainder@X<2\habshe@leading@d
  \ClassError{habshe-tufte}{%
    Layout remainder collapsed to \the\habshe@remainder@X\space on \habshe@papersize%
  }{%
    The 40/20/40 partition needs at least two leadings of slack.\MessageBreak
    Reduce 'fontsize' or choose a wider 'papersize'.%
  }%
\fi

\newdimen\habshe@margin@left@d
\newdimen\habshe@margin@right@d
\newdimen\habshe@gutter@d
\newdimen\habshe@fullwidth@d

\setlength\habshe@margin@left@d {\fpeval{0.40 * \habshe@remainder@X}pt}
\setlength\habshe@margin@right@d{\fpeval{0.40 * \habshe@remainder@X}pt}
\setlength\habshe@gutter@d      {\fpeval{0.20 * \habshe@remainder@X}pt}
\setlength\habshe@fullwidth@d   {\fpeval{\paperwidth - \habshe@margin@left@d - \habshe@margin@right@d}pt}

% ---- Vertical canvas ----------------------------------------------------
% D6 (parked): headheight/headsep/footskip are reserved-but-unused
% bands ("unusable band, then usable band" model, mirroring the
% margin). topskip = 1.0L is provisional; a true baseline grid is
% v0.9 scope.
\newdimen\habshe@margin@top@d
\newdimen\habshe@margin@bottom@d
\newdimen\habshe@headheight@d
\newdimen\habshe@headsep@d
\newdimen\habshe@footskip@d
\newdimen\habshe@topskip@d

\setlength\habshe@margin@top@d    {\fpeval{5.0 * \habshe@leading@d}pt}
\setlength\habshe@margin@bottom@d {\fpeval{6.25 * \habshe@leading@d}pt}
\setlength\habshe@headheight@d    {\fpeval{1.0 * \habshe@leading@d}pt}
\setlength\habshe@headsep@d       {\fpeval{1.5 * \habshe@leading@d}pt}
\setlength\habshe@footskip@d      {\fpeval{2.5 * \habshe@leading@d}pt}
\setlength\habshe@topskip@d       {\fpeval{1.0 * \habshe@leading@d}pt}

% ---- Geometry integration ----------------------------------------------
\RequirePackage{geometry}
\geometry{
  \habshe@papersize,
  left            = \habshe@margin@left@d,
  top             = \habshe@margin@top@d,
  bottom          = \habshe@margin@bottom@d,
  includeheadfoot = true,
  includemp       = true,
  headheight      = \habshe@headheight@d,
  headsep         = \habshe@headsep@d,
  footskip        = \habshe@footskip@d,
  textwidth       = \habshe@bodywidth@d,
  marginparsep    = \habshe@gutter@d,
  marginparwidth  = \habshe@marginwidth@d,
}

% ---- Margin note formatting ----------------------------------------------
\renewcommand*\@marginparreset{%
  \reset@font
  \habshe@marginnote@size
  \raggedright
  \slshape}

% ==================================================================
% §5  LAYOUT STREAMS
% ------------------------------------------------------------------
% Purpose: The two horizontal streams (full-width / tufte) as a state
% machine with scoped environments, plus the marginpar guard.
% Owns:    \habshe@layout@state, \ifhabshe@in@heading, the setters,
%   both environments, the shorthands, the marginpar override.
%   Depends: §4 (measure registers); §6 sets \ifhabshe@in@heading.
%     Affects: \hsize, \linewidth, \marginparwidth, \marginparsep, and
%     whether \marginpar is legal.
%     Notes:   State encoding: 0 = full-width, 1 = tufte. The document
%     starts in full-width (§9). Margin notes are illegal (a) in
%     the full-width stream and (b) inside heading titles —
%     headings are full-width blocks and own their margin band.
%     ==================================================================

\chardef\habshe@layout@state=0
\newif\ifhabshe@in@heading
\habshe@in@headingfalse

\newcommand{\setlayoutfullwidth}{%
  \par
  \chardef\habshe@layout@state=0
  \setlength\hsize{\habshe@fullwidth@d}%
  \setlength\linewidth{\hsize}%
}

\newcommand{\setlayouttufte}{%
  \par
  \chardef\habshe@layout@state=1
  \setlength\hsize{\habshe@bodywidth@d}%
  \setlength\linewidth{\hsize}%
  \setlength\marginparwidth{\habshe@marginwidth@d}%
  \setlength\marginparsep{\habshe@gutter@d}%
}

% Scoped environments: save state, switch, restore on exit.
\newenvironment{layoutfullwidth}{%
  \par
  \chardef\habshe@saved@state=\habshe@layout@state
  \setlayoutfullwidth
}{%
  \par
  \ifcase\habshe@saved@state
    \setlayoutfullwidth
  \or
    \setlayouttufte
  \fi
}

\newenvironment{layouttufte}{%
  \par
  \chardef\habshe@saved@state=\habshe@layout@state
  \setlayouttufte
}{%
  \par
  \ifcase\habshe@saved@state
    \setlayoutfullwidth
  \or
    \setlayouttufte
  \fi
}

% Declarative shorthands (persistent switches).
\newcommand{\fullwidth}{\setlayoutfullwidth}
\newcommand{\tufte}{\setlayouttufte}

% Margin note guard. Order matters: the in-heading check comes first
% because a heading can occur while the ambient state is tufte.
\let\habshe@orig@marginpar\marginpar
\renewcommand{\marginpar}[2][]{%
  \ifhabshe@in@heading
    \ClassWarning{habshe-tufte}{%
      \string\marginpar\space omitted: illegal inside a heading title%
    }%
  \else
    \ifcase\habshe@layout@state
      \ClassWarning{habshe-tufte}{%
        \string\marginpar\space omitted: illegal in full-width layout%
      }%
    \or
      \if\relax\detokenize{#1}\relax
        \habshe@orig@marginpar{#2}%
      \else
        \habshe@orig@marginpar[#1]{#2}%
      \fi
    \fi
  \fi
}

% ==================================================================
% §6  SECTIONING
% ------------------------------------------------------------------
% Purpose: The five heading levels, full-width heading typesetting,
% counters, marks, and (provisional) TOC hooks.
% Owns:    The five counters, heading skip registers, TOC indent
% registers, \habshe@heading@format, the level commands.
% Depends: §2 (\habshe@glue), §3 (NFSS tiers, \habshe@leading@d),
% §4 (\habshe@fullwidth@d), §5 (heading flag).
% Affects: \subject, \heading, \subheading, \subsubheading,
% \subsubsubheading, TOC formatting.
% Notes:   CONSTRAINT (kernel contract): \habshe@heading@format relies
% on \at's "positive afterskip" branch, which calls the
% style argument as #6{...} in VERTICAL mode. Never pass a
% negative afterskip to these \startsection definitions:
% the run-in branch calls #6 in horizontal mode and the
% leading \par would split the paragraph.
% PARKED (S2): tocdepth is provisional; a dedicated TOC
% package will own the look and the depth later.
% ==================================================================

\setcounter{secnumdepth}{0}
\setcounter{tocdepth}{3} % provisional (stops at subsubheading); TOC package revisits

\newcounter{subject}
\newcounter{heading}[subject]
\newcounter{subheading}[heading]
\newcounter{subsubheading}[subheading]
\newcounter{subsubsubheading}[subsubheading]

\let\subjectmark\@gobble
\let\headingmark\@gobble
\let\subheadingmark\@gobble
\let\subsubheadingmark\@gobble
\let\subsubsubheadingmark\@gobble

% Heading vertical skips. Negative beforeskip with negative stretch
% suppresses the post-heading paragraph indent (kernel sign rule:
% negation flips plus and minus too). Applied by \xsect as plain
% \vskip — NOT \addvspace; see v0.9 pass for stacking behavior.
\newskip\habshe@subject@before
\newskip\habshe@subject@after
\newskip\habshe@heading@before
\newskip\habshe@heading@after
\newskip\habshe@subheading@before
\newskip\habshe@subheading@after
\newskip\habshe@subsubheading@before
\newskip\habshe@subsubheading@after
\newskip\habshe@subsubsubheading@before
\newskip\habshe@subsubsubheading@after

\setlength\habshe@subject@before        {\habshe@glue{\habshe@leading@d}{-3.0}{-0.5}{-0.2}}
\setlength\habshe@subject@after         {\habshe@glue{\habshe@leading@d}{1.5}{0.2}{0.0}}
\setlength\habshe@heading@before         {\habshe@glue{\habshe@leading@d}{-2.5}{-0.4}{-0.2}}
\setlength\habshe@heading@after          {\habshe@glue{\habshe@leading@d}{1.2}{0.15}{0.0}}
\setlength\habshe@subheading@before      {\habshe@glue{\habshe@leading@d}{-2.0}{-0.3}{-0.1}}
\setlength\habshe@subheading@after      {\habshe@glue{\habshe@leading@d}{1.0}{0.1}{0.0}}
\setlength\habshe@subsubheading@before   {\habshe@glue{\habshe@leading@d}{-1.5}{-0.2}{-0.1}}
\setlength\habshe@subsubheading@after   {\habshe@glue{\habshe@leading@d}{0.8}{0.1}{0.0}}
\setlength\habshe@subsubsubheading@before{\habshe@glue{\habshe@leading@d}{-1.2}{-0.2}{-0.1}}
\setlength\habshe@subsubsubheading@after {\habshe@glue{\habshe@leading@d}{0.6}{0.1}{0.0}}

% PARKED (S2): TOC geometry is provisional regular-scaled statics.
\newdimen\habshe@toc@indent@z
\newdimen\habshe@toc@indent@i
\newdimen\habshe@toc@indent@ii
\newdimen\habshe@toc@indent@iii
\newdimen\habshe@toc@indent@iv
\newdimen\habshe@toc@numwidth@z
\newdimen\habshe@toc@numwidth@i
\newdimen\habshe@toc@numwidth@ii
\newdimen\habshe@toc@numwidth@iii
\newdimen\habshe@toc@numwidth@iv

\setlength\habshe@toc@indent@z   {\z@}
\setlength\habshe@toc@indent@i   {\z@}
\setlength\habshe@toc@indent@ii  {\fpeval{1.5 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@indent@iii {\fpeval{3.8 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@indent@iv  {\fpeval{7.0 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@numwidth@z   {\fpeval{2.0 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@numwidth@i   {\fpeval{2.0 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@numwidth@ii  {\fpeval{2.3 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@numwidth@iii {\fpeval{3.2 * \habshe@size@regular@d}pt}
\setlength\habshe@toc@numwidth@iv  {\fpeval{4.1 * \habshe@size@regular@d}pt}

\newcommand*\l@subject        {\@dottedtocline{1}{\habshe@toc@indent@z}{\habshe@toc@numwidth@z}}
\newcommand*\l@heading        {\@dottedtocline{2}{\habshe@toc@indent@i}{\habshe@toc@numwidth@i}}
\newcommand*\l@subheading     {\@dottedtocline{3}{\habshe@toc@indent@ii}{\habshe@toc@numwidth@ii}}
\newcommand*\l@subsubheading  {\@dottedtocline{4}{\habshe@toc@indent@iii}{\habshe@toc@numwidth@iii}}
\newcommand*\l@subsubsubheading{\@dottedtocline{5}{\habshe@toc@indent@iv}{\habshe@toc@numwidth@iv}}

% Heading wrapper: re-hsize the title paragraph to the full width and
% flag the heading band so the §5 guard suppresses margin notes placed
% inside titles (the state alone cannot catch this in tufte mode).
\newcommand{\habshe@heading@format}[2]{%
  \par
  \begingroup
  \habshe@in@headingtrue
  \setlength\hsize{\habshe@fullwidth@d}%
  \setlength\linewidth{\habshe@fullwidth@d}%
  #1#2\par
  \habshe@in@headingfalse
  \endgroup
}

\newcommand{\subject}{\@startsection{subject}{1}{\z@}%
  {\habshe@subject@before}%
  {\habshe@subject@after}%
  {\habshe@heading@format{\normalfont\Huge\bfseries\raggedright}}}

\newcommand{\heading}{\@startsection{heading}{2}{\z@}%
  {\habshe@heading@before}%
  {\habshe@heading@after}%
  {\habshe@heading@format{\normalfont\huge\bfseries\raggedright}}}

\newcommand{\subheading}{\@startsection{subheading}{3}{\z@}%
  {\habshe@subheading@before}%
  {\habshe@subheading@after}%
  {\habshe@heading@format{\normalfont\LARGE\bfseries\raggedright}}}

\newcommand{\subsubheading}{\@startsection{subsubheading}{4}{\z@}%
  {\habshe@subsubheading@before}%
  {\habshe@subsubheading@after}%
  {\habshe@heading@format{\normalfont\Large\bfseries\raggedright}}}

\newcommand{\subsubsubheading}{\@startsection{subsubsubheading}{5}{\z@}%
  {\habshe@subsubsubheading@before}%
  {\habshe@subsubsubheading@after}%
  {\habshe@heading@format{\normalfont\large\bfseries\raggedright}}}

% ==================================================================
% §7  STRUCTURAL ENVIRONMENTS
% ------------------------------------------------------------------
% Purpose: topic / subtopic — labeled blocks with run-in titles.
% Owns:    \habshe@topicskip, \habshe@subtopicskip,
% \habshe@runinsep@s / \habshe@runinsep, both environments.
% Depends: §2 (\habshe@glue), §3 (\regular, \SMALL, \small),
% §4/§3 (\habshe@leading@d).
% Affects: document structure commands topic, subtopic.
% Notes:   Convention: topic body runs at the ambient size (SMALL);
% topic labels one tier up (regular), subtopic labels at
% SMALL with body at small — top of body range down.
% \addvspace collapses adjacent topic margins correctly.
% ==================================================================

\newskip\habshe@topicskip
\newskip\habshe@subtopicskip
\setlength\habshe@topicskip   {\habshe@glue{\habshe@leading@d}{1.50}{0.2}{0.1}}
\setlength\habshe@subtopicskip{\habshe@glue{\habshe@leading@d}{1.25}{0.2}{0.1}}

% Run-in separator: elastic horizontal glue after a run-in label.
\newskip\habshe@runinsep@s
\setlength\habshe@runinsep@s{%
  \habshe@glue{\habshe@size@regular@d}{0.8}{0.25}{0.15}}
\newcommand{\habshe@runinsep}{\hskip\habshe@runinsep@s\relax}

% Topic: regular bold run-in, SMALL body, unindented first line.
\newenvironment{topic}[1][]{%
  \par
  \addvspace{\habshe@topicskip}%
  \begingroup
  \noindent
  \if\relax\detokenize{#1}\relax\else
    {\regular\bfseries #1\habshe@runinsep}%
  \fi
  \SMALL\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@topicskip}%
}

% Subtopic: SMALL bold run-in, small body, indented first line.
\newenvironment{subtopic}[1][]{%
  \par
  \addvspace{\habshe@subtopicskip}%
  \begingroup
  \indent
  \if\relax\detokenize{#1}\relax\else
    {\SMALL\bfseries #1\habshe@runinsep}%
  \fi
  \small\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@subtopicskip}%
}

% ==================================================================
% §8  BASELINE APPLICATION
% ------------------------------------------------------------------
% Purpose: THE single place where the class assigns LaTeX's global
% paragraph/list parameters from its registers. Audit rule:
% anything that touches a kernel parameter outside §1 (class
% load), §3 (\normalsize internals), §4 (geometry) or §5
% (layout setters) is a bug.
% Owns:    The static registers applied here (parindent, labelsep,
% leftmargins, emergencystretch, parskip).
% Depends: §2 (\fpeval), §3 (\habshe@size@regular@d, \habshe@leading@d).
% Affects: \parindent, \parskip, \topskip, \splittopskip,
% \emergencystretch, \labelsep, \labelwidth,
% \leftmargini..iv, \marginparpush.
% Notes:   Statics are scaled by the REGULAR tier as the canonical
% character unit (v0.7 behavior, deliberately kept): regular
% is the top of the reserved body range. Whether ambient-
% scaled statics are better is a v0.9 question.
% ==================================================================

\newdimen\habshe@parindent@d
\newdimen\habshe@labelsep@d
\newdimen\habshe@leftmargini@d
\newdimen\habshe@leftmarginii@d
\newdimen\habshe@leftmarginiii@d
\newdimen\habshe@leftmarginiv@d
\newdimen\habshe@emergencystretch@d
\newdimen\habshe@parskip@d

\setlength\habshe@parindent@d        {\fpeval{1.0 * \habshe@size@regular@d}pt}
\setlength\habshe@labelsep@d         {\fpeval{0.5 * \habshe@size@regular@d}pt}
\setlength\habshe@leftmargini@d      {\fpeval{2.0 * \habshe@size@regular@d}pt}
\setlength\habshe@leftmarginii@d     {\fpeval{1.5 * \habshe@size@regular@d}pt}
\setlength\habshe@leftmarginiii@d   {\fpeval{1.2 * \habshe@size@regular@d}pt}
\setlength\habshe@leftmarginiv@d    {\fpeval{1.0 * \habshe@size@regular@d}pt}
\setlength\habshe@emergencystretch@d {\fpeval{1.5 * \habshe@size@regular@d}pt}
\setlength\habshe@parskip@d          {\z@}

\setlength\parindent{\habshe@parindent@d}
\setlength\parskip{\habshe@parskip@d}
\setlength\topskip{\habshe@topskip@d}
\setlength\splittopskip{\habshe@topskip@d}
\setlength\emergencystretch{\habshe@emergencystretch@d}
\setlength\labelsep{\habshe@labelsep@d}
\setlength\leftmargini{\habshe@leftmargini@d}
\setlength\leftmarginii{\habshe@leftmarginii@d}
\setlength\leftmarginiii{\habshe@leftmarginiii@d}
\setlength\leftmarginiv{\habshe@leftmarginiv@d}
\setlength\labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\setlength\marginparpush{\habshe@leading@d}

% ==================================================================
% §9  RUNTIME INIT
% ------------------------------------------------------------------
% Purpose: Final global posture and the computed-matrix log dump.
% Owns:    The \AtBeginDocument hook, \raggedbottom, \pagestyle.
% Depends: §4, §5 (everything, for the dump and initial layout).
% Affects: Page breaking style, page style, initial layout stream,
% the class's entry in main.log.
% Notes:   The matrix dump is the S3 audit trail: every value below
% came out of a §2 formula on THIS run, so the log entry is
% the proof the engine produced what the spec intended.
% ==================================================================

\raggedbottom
\pagestyle{empty}

% The document begins in the full-width stream.
\AtBeginDocument{\setlayoutfullwidth}

\ClassInfo{habshe-tufte}{%
  Computed layout matrix:\MessageBreak
  \space\space seed fontsize (F)   = \the\habshe@fontsize@d \MessageBreak
  \space\space SMALL (ambient)     = \the\habshe@size@SMALL@d \MessageBreak
  \space\space regular             = \the\habshe@size@regular@d \MessageBreak
  \space\space base leading (L)   = \the\habshe@leading@d \MessageBreak
  \space\space body width          = \the\habshe@bodywidth@d \MessageBreak
  \space\space margin width       = \the\habshe@marginwidth@d \MessageBreak
  \space\space gutter              = \the\habshe@gutter@d \MessageBreak
  \space\space left/right margin   = \the\habshe@margin@left@d \MessageBreak
  \space\space remainder X         = \the\habshe@remainder@X \MessageBreak
  \space\space full width          = \the\habshe@fullwidth@d \MessageBreak
  \space\space margin note size    = \habshe@marginnote@size\ (Tiny tier)%
}

\endinput
