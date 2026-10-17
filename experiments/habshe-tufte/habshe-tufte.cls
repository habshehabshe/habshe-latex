%% 
%% habshe-tufte.cls
%% A Tufte-inspired notes class built on article.cls with geometry integration.
%% Version 0.6 (2026-10-17)
%% 

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{habshe-tufte}[2026-10-17 v0.6 Standalone Proportional Notes Class]

% ==================================================================
% 1. Option Processing & Delegation
% ==================================================================
\DeclareKeys{
  paper    .store = \habshe@paper,
  fontsize .store = \habshe@fontsize@raw,
  \unknown .code  = {\PassOptionsToClass{\CurrentOption}{article}}
}

% Default options
\def\habshe@paper{a4}
\def\habshe@fontsize@raw{10pt}

\ProcessKeyOptions\relax

% Normalize paper name so both "a4" and "a4paper" are accepted
\def\habshe@strip@paper#1paper#2\@nil{#1paper}
\edef\habshe@papername{%
  \expandafter\habshe@strip@paper\habshe@paper paper\@nil
}

% Forward normalized paper size to article
\PassOptionsToClass{\habshe@papername}{article}
\LoadClass{article}

% ==================================================================
% 2. Typographic Seeds & Proportional Engine
% ==================================================================
% Convert input fontsize string to dimensions and bare numbers
\newdimen\habshe@fontsize@d
\setlength\habshe@fontsize@d{\habshe@fontsize@raw}
\edef\habshe@fontsize@num{\strip@pt\habshe@fontsize@d}

% Leading L = 1.2 * Fontsize
\newdimen\habshe@leading@d
\setlength\habshe@leading@d{1.2\habshe@fontsize@d}

% ==================================================================
% 3. Centralized Spacing Matrix
% ==================================================================
% --- 3.1 Horizontal Static Dimensions ---
\setlength\parindent{\habshe@fontsize@d} % 1.0em = Fontsize
\setlength\labelsep{0.5\habshe@fontsize@d}
\setlength\leftmargini{2.0\habshe@fontsize@d}
\setlength\leftmarginii{1.5\habshe@fontsize@d}
\setlength\leftmarginiii{1.2\habshe@fontsize@d}
\setlength\leftmarginiv{1.0\habshe@fontsize@d}
\setlength\labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}

% Elastic run-in separator (prevents overfull \hbox on narrow measures)
\newcommand{\habshe@runinsep}{%
  \hskip 0.8\habshe@fontsize@d 
  \@plus 0.25\habshe@fontsize@d 
  \@minus 0.15\habshe@fontsize@d\relax
}

% --- 3.2 Horizontal Dynamic & Canvas Partitioning ---
\newdimen\habshe@margin@left@d
\newdimen\habshe@margin@right@d
\newdimen\habshe@bodywidth@d
\newdimen\habshe@gutter@d
\newdimen\habshe@marginwidth@d
\newdimen\habshe@fullwidth@d

% Unusable outer blank margins
\setlength\habshe@margin@left@d{1.0in}
\setlength\habshe@margin@right@d{1.0in}

% Tufte optimal measure: ~65 characters ≈ 31.2em (26pc at 10pt)
\setlength\habshe@bodywidth@d{31.2\habshe@fontsize@d}

% Gutter between body and marginal notes
\setlength\habshe@gutter@d{1.5pc}

% Usable marginal notes width = Paper - (Left + Right + Body + Gutter)
\setlength\habshe@marginwidth@d{%
  \dimexpr\paperwidth - \habshe@margin@left@d - \habshe@margin@right@d 
  - \habshe@bodywidth@d - \habshe@gutter@d\relax
}

% Full-width text area (spanning body + gutter + margin)
\setlength\habshe@fullwidth@d{%
  \dimexpr\habshe@bodywidth@d + \habshe@gutter@d + \habshe@marginwidth@d\relax
}

% --- 3.3 Vertical Static Dimensions ---
\newdimen\habshe@margin@top@d
\newdimen\habshe@margin@bottom@d
\newdimen\habshe@headheight@d
\newdimen\habshe@headsep@d
\newdimen\habshe@footskip@d

\setlength\habshe@margin@top@d{1.0in}
\setlength\habshe@margin@bottom@d{1.25in}
\setlength\habshe@headheight@d{1.0\habshe@leading@d}
\setlength\habshe@headsep@d{1.5\habshe@leading@d}
\setlength\habshe@footskip@d{2.5\habshe@leading@d}

\setlength\topskip{\habshe@leading@d}
\setlength\splittopskip{\habshe@leading@d}
\setlength\parskip{0\p@}
\setlength\emergencystretch{1.5em}

% --- 3.4 Vertical Dynamic Skips (Derived from Leading L) ---
\newskip\habshe@displayskip
\newskip\habshe@displayshortskip
\newskip\habshe@belowdisplayshortskip
\newskip\habshe@topicskip
\newskip\habshe@subtopicskip

\setlength\habshe@displayskip{%
  \glueexpr 1.0\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@displayshortskip{%
  \glueexpr 0.0\habshe@leading@d plus 0.2\habshe@leading@d\relax
}
\setlength\habshe@belowdisplayshortskip{%
  \glueexpr 0.5\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@topicskip{%
  \glueexpr 1.5\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subtopicskip{%
  \glueexpr 1.0\habshe@leading@d plus 0.15\habshe@leading@d minus 0.1\habshe@leading@d\relax
}

% Section Skips (negative beforeskip suppresses post-heading indent)
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

\setlength\habshe@subject@before{%
  \glueexpr -2.5\habshe@leading@d plus -0.5\habshe@leading@d minus -0.2\habshe@leading@d\relax
}
\setlength\habshe@subject@after{%
  \glueexpr 1.2\habshe@leading@d plus 0.2\habshe@leading@d\relax
}
\setlength\habshe@heading@before{%
  \glueexpr -2.0\habshe@leading@d plus -0.4\habshe@leading@d minus -0.2\habshe@leading@d\relax
}
\setlength\habshe@heading@after{%
  \glueexpr 1.0\habshe@leading@d plus 0.15\habshe@leading@d\relax
}
\setlength\habshe@subheading@before{%
  \glueexpr -1.6\habshe@leading@d plus -0.3\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subheading@after{%
  \glueexpr 0.8\habshe@leading@d plus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubheading@before{%
  \glueexpr -1.3\habshe@leading@d plus -0.2\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubheading@after{%
  \glueexpr 0.6\habshe@leading@d plus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubsubheading@before{%
  \glueexpr -1.1\habshe@leading@d plus -0.2\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubsubheading@after{%
  \glueexpr 0.5\habshe@leading@d plus 0.1\habshe@leading@d\relax
}

% ==================================================================
% 4. NFSS Typography Scale Engine
% ==================================================================
\DeclareRobustCommand\normalsize{%
  \@setfontsize\normalsize{\habshe@fontsize@num}{\habshe@leading@d}%
  \abovedisplayskip\habshe@displayskip
  \belowdisplayskip\habshe@displayskip
  \abovedisplayshortskip\habshe@displayshortskip
  \belowdisplayshortskip\habshe@belowdisplayshortskip
  \let\@listi\@listI
}
\normalsize

\DeclareRobustCommand\small{%
  \@setfontsize\small{\strip@pt\dimexpr 0.9\habshe@fontsize@d\relax}{%
    \dimexpr 0.85\habshe@leading@d\relax}%
}
\DeclareRobustCommand\footnotesize{%
  \@setfontsize\footnotesize{\strip@pt\dimexpr 0.8\habshe@fontsize@d\relax}{%
    \dimexpr 0.72\habshe@leading@d\relax}%
}
\DeclareRobustCommand\scriptsize{%
  \@setfontsize\scriptsize{\strip@pt\dimexpr 0.7\habshe@fontsize@d\relax}{%
    \dimexpr 0.57\habshe@leading@d\relax}%
}
\DeclareRobustCommand\tiny{%
  \@setfontsize\tiny{\strip@pt\dimexpr 0.5\habshe@fontsize@d\relax}{%
    \dimexpr 0.43\habshe@leading@d\relax}%
}
\DeclareRobustCommand\large{%
  \@setfontsize\large{\strip@pt\dimexpr 1.1\habshe@fontsize@d\relax}{%
    \dimexpr 1.1\habshe@leading@d\relax}%
}
\DeclareRobustCommand\Large{%
  \@setfontsize\Large{\strip@pt\dimexpr 1.25\habshe@fontsize@d\relax}{%
    \dimexpr 1.25\habshe@leading@d\relax}%
}
\DeclareRobustCommand\LARGE{%
  \@setfontsize\LARGE{\strip@pt\dimexpr 1.45\habshe@fontsize@d\relax}{%
    \dimexpr 1.45\habshe@leading@d\relax}%
}
\DeclareRobustCommand\huge{%
  \@setfontsize\huge{\strip@pt\dimexpr 1.8\habshe@fontsize@d\relax}{%
    \dimexpr 1.8\habshe@leading@d\relax}%
}
\DeclareRobustCommand\Huge{%
  \@setfontsize\Huge{\strip@pt\dimexpr 2.2\habshe@fontsize@d\relax}{%
    \dimexpr 2.2\habshe@leading@d\relax}%
}

% List vertical spacing hooks
\def\@listi{%
  \leftmargin\leftmargini
  \parsep 0\p@ \@plus 0.05\habshe@leading@d
  \topsep 0.5\habshe@leading@d \@plus 0.15\habshe@leading@d \@minus 0.1\habshe@leading@d
  \itemsep 0.25\habshe@leading@d \@plus 0.1\habshe@leading@d}
\let\@listI\@listi

\def\@listii{%
  \leftmargin\leftmarginii
  \labelwidth\leftmarginii
  \advance\labelwidth-\labelsep
  \topsep 0.25\habshe@leading@d \@plus 0.1\habshe@leading@d
  \parsep 0\p@
  \itemsep\parsep}

% ==================================================================
% 5. Page Geometry Initialization (Piggyback Solver)
% ==================================================================
\RequirePackage{geometry}
\geometry{
  \habshe@papername,
  left           = \habshe@margin@left@d,
  top            = \habshe@margin@top@d,
  bottom         = \habshe@margin@bottom@d,
  includeheadfoot= true,
  includemp      = true,
  headheight     = \habshe@headheight@d,
  headsep        = \habshe@headsep@d,
  footskip       = \habshe@footskip@d,
  textwidth      = \habshe@bodywidth@d,
  marginparsep   = \habshe@gutter@d,
  marginparwidth = \habshe@marginwidth@d,
}
\raggedbottom
\pagestyle{empty}

% Configure margin notes to sit neatly in Tufte fashion
\renewcommand*\@marginparreset{%
  \reset@font\footnotesize
  \raggedright
  \slshape
}

% Graceful protection: suppress marginpars in full-width mode
\let\habshe@orig@marginpar\marginpar
\renewcommand{\marginpar}[2][]{%
  \if@habshe@tufte
    \if\relax\detokenize{#1}\relax
      \habshe@orig@marginpar{#2}%
    \else
      \habshe@orig@marginpar[#1]{#2}%
    \fi
  \else
    \ClassWarning{habshe-tufte}{%
      \string\marginpar\space omitted: illegal in full-width layout%
    }%
  \fi
}

% ==================================================================
% 6. Layout Streams: Full-Width (FW) vs. Tufte (T)
% ==================================================================
\newif\if@habshe@tufte
\@habshe@tuftefalse

\newcommand{\setlayoutfullwidth}{%
  \par
  \@habshe@tuftefalse
  \setlength\hsize{\habshe@fullwidth@d}%
  \setlength\linewidth{\hsize}%
}

\newcommand{\setlayouttufte}{%
  \par
  \@habshe@tuftetrue
  \setlength\hsize{\habshe@bodywidth@d}%
  \setlength\linewidth{\hsize}%
}

% Scoped layout environments
\newenvironment{layoutfullwidth}{%
  \par
  \edef\habshe@saved@stream{\if@habshe@tufte 1\else 0\fi}%
  \setlayoutfullwidth
}{%
  \par
  \ifnum\habshe@saved@stream=1 \setlayouttufte\else\setlayoutfullwidth\fi
}

\newenvironment{layouttufte}{%
  \par
  \edef\habshe@saved@stream{\if@habshe@tufte 1\else 0\fi}%
  \setlayouttufte
}{%
  \par
  \ifnum\habshe@saved@stream=1 \setlayouttufte\else\setlayoutfullwidth\fi
}

% Backward-compatible shorthands
\newcommand{\fullwidth}{\setlayoutfullwidth}
\newcommand{\tufte}{\setlayouttufte}

% Start the document in Full-Width mode
\AtBeginDocument{\setlayoutfullwidth}

% ==================================================================
% 7. Custom Sectioning Architecture
% ==================================================================
\setcounter{secnumdepth}{0}

\newcounter{subject}
\newcounter{heading}[subject]
\newcounter{subheading}[heading]
\newcounter{subsubheading}[subheading]
\newcounter{subsubsubheading}[subsubheading]

% Prevent headings from leaking into body text via missing mark macros
\let\subjectmark\@gobble
\let\headingmark\@gobble
\let\subheadingmark\@gobble
\let\subsubheadingmark\@gobble
\let\subsubsubheadingmark\@gobble

% Table of Contents hooks
\newcommand*\l@subject{\@dottedtocline{1}{0em}{2.0em}}
\newcommand*\l@heading{\@dottedtocline{2}{0em}{2.0em}}
\newcommand*\l@subheading{\@dottedtocline{3}{1.5em}{2.3em}}
\newcommand*\l@subsubheading{\@dottedtocline{4}{3.8em}{3.2em}}
\newcommand*\l@subsubsubheading{\@dottedtocline{5}{7.0em}{4.1em}}

\newcommand{\subject}{\@startsection{subject}{1}{\z@}%
  {\habshe@subject@before}%
  {\habshe@subject@after}%
  {\normalfont\Huge\bfseries\raggedright}}

\newcommand{\heading}{\@startsection{heading}{2}{\z@}%
  {\habshe@heading@before}%
  {\habshe@heading@after}%
  {\normalfont\huge\bfseries\raggedright}}

\newcommand{\subheading}{\@startsection{subheading}{3}{\z@}%
  {\habshe@subheading@before}%
  {\habshe@subheading@after}%
  {\normalfont\LARGE\bfseries\raggedright}}

\newcommand{\subsubheading}{\@startsection{subsubheading}{4}{\z@}%
  {\habshe@subsubheading@before}%
  {\habshe@subsubheading@after}%
  {\normalfont\Large\bfseries\raggedright}}

\newcommand{\subsubsubheading}{\@startsection{subsubsubheading}{5}{\z@}%
  {\habshe@subsubsubheading@before}%
  {\habshe@subsubsubheading@after}%
  {\normalfont\large\bfseries\raggedright}}

% ==================================================================
% 8. Topic & Subtopic Environments
% ==================================================================
% Topic: Normalsize bold run-in, small regular body, unindented first line
\newenvironment{topic}[1][]{%
  \par
  \addvspace{\habshe@topicskip}%
  \begingroup
  \noindent
  \if\relax\detokenize{#1}\relax\else
    {\normalsize\bfseries #1\habshe@runinsep}%
  \fi
  \small\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@topicskip}%
}

% Subtopic: Small bold run-in, small regular body, indented first line
\newenvironment{subtopic}[1][]{%
  \par
  \addvspace{\habshe@subtopicskip}%
  \begingroup
  \indent
  \if\relax\detokenize{#1}\relax\else
    {\small\bfseries #1\habshe@runinsep}%
  \fi
  \small\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@subtopicskip}%
}

\endinput
