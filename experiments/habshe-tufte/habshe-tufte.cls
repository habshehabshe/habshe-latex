%% 
%% habshe-tufte.cls
%% A Tufte-inspired notes class built on article.cls
%% 

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{habshe-tufte}[2026-10-16 v0.5 Custom Tufte Notes Class]

% ------------------------------------------------------------------
% 1. Key-Value Option Declarations (Kernel \DeclareKeys)
% ------------------------------------------------------------------
\DeclareKeys{
  paper          .store = \habshe@paper,
  fontsize       .store = \habshe@fontsize@raw,
  leading        .store = \habshe@leading@raw,
  bodywidth      .store = \habshe@bodywidth@raw,
  marginwidth    .store = \habshe@marginwidth@raw,
  gutter         .store = \habshe@gutter@raw,
  topmargin      .store = \habshe@topmargin@raw,
  parindent      .store = \habshe@parindent@raw,
  topic-scale    .store = \habshe@topic@scale,
  subtopic-scale .store = \habshe@subtopic@scale,
}

% High-level default values
\def\habshe@paper{letter}
\def\habshe@fontsize@raw{10}
\def\habshe@leading@raw{14pt}
\def\habshe@bodywidth@raw{26pc}
\def\habshe@marginwidth@raw{12pc}
\def\habshe@gutter@raw{2pc}
\def\habshe@topmargin@raw{1in}
\def\habshe@parindent@raw{1.0pc}
\def\habshe@topic@scale{2.0}
\def\habshe@subtopic@scale{1.5}

% Process options provided to \documentclass[...]
\ProcessKeyOptions\relax

% ------------------------------------------------------------------
% 2. Base Class Loading & Paper Dimensions
% ------------------------------------------------------------------
\def\habshe@opt@aFour{a4}
\ifx\habshe@paper\habshe@opt@aFour
  \PassOptionsToClass{a4paper}{article}
  \setlength\paperwidth{210mm}
  \setlength\paperheight{297mm}
\else
  \PassOptionsToClass{letterpaper}{article}
  \setlength\paperwidth{8.5in}
  \setlength\paperheight{11in}
\fi

\LoadClass{article}

% Internal dimension registers
\newdimen\habshe@bodywidth@d
\newdimen\habshe@marginwidth@d
\newdimen\habshe@gutter@d
\newdimen\habshe@topmargin@d
\newdimen\habshe@leading@d

\setlength\habshe@bodywidth@d  {\habshe@bodywidth@raw}
\setlength\habshe@marginwidth@d{\habshe@marginwidth@raw}
\setlength\habshe@gutter@d     {\habshe@gutter@raw}
\setlength\habshe@topmargin@d  {\habshe@topmargin@raw}
\setlength\habshe@leading@d    {\habshe@leading@raw}

% ------------------------------------------------------------------
% 3. Core Typography & Spacing Overrides
% ------------------------------------------------------------------
\setlength\topskip{\habshe@leading@d}
\setlength\splittopskip{\habshe@leading@d}
\setlength\parskip{0\p@}
\setlength\parindent{\habshe@parindent@raw}

% \emergencystretch allows TeX flexibility on narrow columns to prevent overfull boxes
\setlength\emergencystretch{1.5em}

\pagenumbering{arabic}
\pagestyle{empty}

% ------------------------------------------------------------------
% 4. Page Geometry
% ------------------------------------------------------------------
\RequirePackage{geometry}
\geometry{
  paperwidth=\paperwidth,
  paperheight=\paperheight,
  left=1in,
  top=\habshe@topmargin@d,
  headheight=\habshe@leading@d,
  headsep=\dimexpr 2\habshe@leading@d\relax,
  textwidth=\habshe@bodywidth@d,
  marginparsep=\habshe@gutter@d,
  marginparwidth=\habshe@marginwidth@d,
  textheight=44\baselineskip,
}
\raggedbottom

% ------------------------------------------------------------------
% 5. Layout Streams: Full-Width (FW) vs. Tufte (T)
% ------------------------------------------------------------------
\newlength\@habshe@fullwidth
\setlength\@habshe@fullwidth{%
  \dimexpr\habshe@bodywidth@d + \habshe@gutter@d + \habshe@marginwidth@d\relax
}

\newif\if@habshe@tufte
\@habshe@tuftefalse

\newcommand{\@habshe@setfullwidth}{%
  \par
  \@habshe@tuftefalse
  \setlength\textwidth{\@habshe@fullwidth}%
  \setlength\hsize{\@habshe@fullwidth}%
  \setlength\linewidth{\@habshe@fullwidth}%
  \setlength\columnwidth{\@habshe@fullwidth}%
}

\newcommand{\@habshe@settufte}{%
  \par
  \@habshe@tuftetrue
  \setlength\textwidth{\habshe@bodywidth@d}%
  \setlength\hsize{\habshe@bodywidth@d}%
  \setlength\linewidth{\habshe@bodywidth@d}%
  \setlength\columnwidth{\habshe@bodywidth@d}%
}

\newcommand{\fullwidth}{\@habshe@setfullwidth}
\newcommand{\tufte}{\@habshe@settufte}

% Start in Full-Width layout stream
\AtBeginDocument{\@habshe@setfullwidth}

% ------------------------------------------------------------------
% 6. Custom Sectioning Architecture
% ------------------------------------------------------------------
\setcounter{secnumdepth}{0}

\newcounter{subject}
\newcounter{heading}[subject]
\newcounter{subheading}[heading]
\newcounter{subsubheading}[subheading]
\newcounter{subsubsubheading}[subsubheading]

% Prevent heading text from leaking into the page body:
\let\subjectmark\@gobble
\let\headingmark\@gobble
\let\subheadingmark\@gobble
\let\subsubheadingmark\@gobble
\let\subsubsubheadingmark\@gobble

% Table of Contents hooks
\newcommand*\l@subject{\@dottedtocline{1}{0em}{2em}}
\newcommand*\l@heading{\@dottedtocline{2}{0em}{2em}}
\newcommand*\l@subheading{\@dottedtocline{3}{1.5em}{2.3em}}
\newcommand*\l@subsubheading{\@dottedtocline{4}{3.8em}{3.2em}}
\newcommand*\l@subsubsubheading{\@dottedtocline{5}{7.0em}{4.1em}}

\newcommand{\subject}{\@startsection{subject}{1}{\z@}%
  {-3.5ex \@plus -1ex \@minus -.2ex}%
  {2.0ex \@plus .2ex}%
  {\normalfont\Huge\bfseries\raggedright}}

\newcommand{\heading}{\@startsection{heading}{2}{\z@}%
  {-3.0ex \@plus -1ex \@minus -.2ex}%
  {1.5ex \@plus .2ex}%
  {\normalfont\huge\bfseries\raggedright}}

\newcommand{\subheading}{\@startsection{subheading}{3}{\z@}%
  {-2.5ex \@plus -1ex \@minus -.2ex}%
  {1.2ex \@plus .2ex}%
  {\normalfont\LARGE\bfseries\raggedright}}

\newcommand{\subsubheading}{\@startsection{subsubheading}{4}{\z@}%
  {-2.0ex \@plus -1ex \@minus -.2ex}%
  {1.0ex \@plus .2ex}%
  {\normalfont\Large\bfseries\raggedright}}

\newcommand{\subsubsubheading}{\@startsection{subsubsubheading}{5}{\z@}%
  {-1.8ex \@plus -1ex \@minus -.2ex}%
  {0.8ex \@plus .2ex}%
  {\normalfont\large\bfseries\raggedright}}

% ------------------------------------------------------------------
% 7. Topic & Subtopic Environments
% ------------------------------------------------------------------
\newskip\habshe@topicskip
\newskip\habshe@subtopicskip

\setlength\habshe@topicskip{%
  \glueexpr \habshe@topic@scale\habshe@leading@d plus 2\p@ minus 1\p@\relax
}
\setlength\habshe@subtopicskip{%
  \glueexpr \habshe@subtopic@scale\habshe@leading@d plus 1.5\p@ minus 1\p@\relax
}

% Elastic label separator to prevent overfull \hbox warnings
\newcommand{\habshe@labelsep}{\hskip 0.8em \@plus 0.25em \@minus 0.15em\relax}

% Topic: Normalsize bold run-in, small regular body, unindented first line
\newenvironment{topic}[1][]{%
  \par
  \addvspace{\habshe@topicskip}%
  \begingroup
  \noindent
  \if\relax\detokenize{#1}\relax\else
    {\normalsize\bfseries #1\habshe@labelsep}%
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
    {\small\bfseries #1\habshe@labelsep}%
  \fi
  \small\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@subtopicskip}%
}

\endinput
