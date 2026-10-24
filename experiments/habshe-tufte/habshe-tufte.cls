%% 
%% habshe-tufte.cls
%% A Tufte-inspired notes class built on article.cls with geometry integration.
%% Version 0.7 (2026-10-18)
%% 

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{habshe-tufte}[2026-10-18 v0.7 Geometric Proportional Notes Class]

\RequirePackage{fix-cm}
\RequirePackage{xfp}

% ==================================================================
% 1. Option Processing & Delegation
% ==================================================================
\DeclareKeys{
  paper    .store = \habshe@paper,
  fontsize .store = \habshe@fontsize@raw,
  \unknown .code  = {\PassOptionsToClass{\CurrentOption}{article}}
}

% Default seed values
\def\habshe@paper{a4}
\def\habshe@fontsize@raw{9pt}

\ProcessKeyOptions\relax

% Normalize paper name (accepts both "a4" and "a4paper")
\def\habshe@strip@paper#1paper#2\@nil{#1paper}
\edef\habshe@papername{%
  \expandafter\habshe@strip@paper\habshe@paper paper\@nil
}

\PassOptionsToClass{\habshe@papername}{article}
\LoadClass{article}

% Base Fontsize Register
\newdimen\habshe@fontsize@d
\setlength\habshe@fontsize@d{\habshe@fontsize@raw}

% ==================================================================
% 2. Centralized Spacing Matrix
% ==================================================================

% ------------------------------------------------------------------
% 2.1.1 Generalized Typographic Scale Formula
% S(k) = F * exp(growth * (k - anchor)) - (k / damper) + lift * max(0, k)^2 + offsett
% ------------------------------------------------------------------

% Formula Parameters
\newcommand{\habshe@scale@growth}{0.07}    % growth (g): Rate of exponential growth
\newcommand{\habshe@scale@anchor}{0}    % anchor (a): Step where exponent evaluation is zero
\newcommand{\habshe@scale@damper}{8}     % damper (d): Linear drag divisor
\newcommand{\habshe@scale@lift}{0.15}    % lift (l): Quadratic tail lift coefficient
\newcommand{\habshe@scale@offset}{-0.75}   % offset (o): Static additive shift in pt

% Register Declarations
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

% Formula Evaluation Macro
\newcommand{\habshe@calc@size}[1]{%
  \fpeval{%
    (
    \habshe@fontsize@d * exp(\habshe@scale@growth * ((#1) - \habshe@scale@anchor))
    - ((#1) / \habshe@scale@damper)
    + (\habshe@scale@lift * (max(0, #1)^2))
    + \habshe@scale@offset
    )
  }pt%
}


% Dimension Assignments
\setlength\habshe@size@HUGE@d      {\habshe@calc@size{8}}
\setlength\habshe@size@Huge@d      {\habshe@calc@size{7}}
\setlength\habshe@size@huge@d      {\habshe@calc@size{6}}
\setlength\habshe@size@LARGE@d     {\habshe@calc@size{5}}
\setlength\habshe@size@Large@d     {\habshe@calc@size{4}}
\setlength\habshe@size@large@d     {\habshe@calc@size{3}}
\setlength\habshe@size@regular@d   {\habshe@calc@size{2}}
\setlength\habshe@size@SMALL@d     {\habshe@calc@size{1}}
\setlength\habshe@size@Small@d     {\habshe@calc@size{0}}
\setlength\habshe@size@small@d     {\habshe@calc@size{-1}}
\setlength\habshe@size@TINY@d      {\habshe@calc@size{-2}}
\setlength\habshe@size@Tiny@d      {\habshe@calc@size{-3}}
\setlength\habshe@size@tiny@d      {\habshe@calc@size{-4}}
\setlength\habshe@size@MINUSCULE@d {\habshe@calc@size{-5}}
\setlength\habshe@size@Minuscule@d {\habshe@calc@size{-6}}
\setlength\habshe@size@minuscule@d {\habshe@calc@size{-7}}

% ------------------------------------------------------------------
% 2.1.2 Generalized Typographic Leading (Baselineskip) Formula
% L(S_k, k) = S_k * ratio_lead - (k / damper_lead) + offset_lead
% ------------------------------------------------------------------

% Formula Parameters
\newcommand{\habshe@lead@ratio}{1.20}      % Current default: 1.2 * Size
\newcommand{\habshe@lead@damper}{999999}   % Set very high to disable dampening for now
\newcommand{\habshe@lead@offset}{0}        % Static additive leading shift in pt

% Register Declarations
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

% Leading Evaluation Macro
% Takes #1 = Size Dimension Register, #2 = Step index k
\newcommand{\habshe@calc@leading}[2]{%
  \fpeval{%
    (
    (#1) * \habshe@lead@ratio
    - ((#2) / \habshe@lead@damper)
    + \habshe@lead@offset
    )
  }pt%
}

% Leading Dimension Assignments
\setlength\habshe@leading@HUGE@d      {\habshe@calc@leading{\habshe@size@HUGE@d}{8}}
\setlength\habshe@leading@Huge@d      {\habshe@calc@leading{\habshe@size@Huge@d}{7}}
\setlength\habshe@leading@huge@d      {\habshe@calc@leading{\habshe@size@huge@d}{6}}
\setlength\habshe@leading@LARGE@d     {\habshe@calc@leading{\habshe@size@LARGE@d}{5}}
\setlength\habshe@leading@Large@d     {\habshe@calc@leading{\habshe@size@Large@d}{4}}
\setlength\habshe@leading@large@d     {\habshe@calc@leading{\habshe@size@large@d}{3}}
\setlength\habshe@leading@regular@d   {\habshe@calc@leading{\habshe@size@regular@d}{2}}
\setlength\habshe@leading@SMALL@d     {\habshe@calc@leading{\habshe@size@SMALL@d}{1}}
\setlength\habshe@leading@Small@d     {\habshe@calc@leading{\habshe@size@Small@d}{0}}
\setlength\habshe@leading@small@d     {\habshe@calc@leading{\habshe@size@small@d}{-1}}
\setlength\habshe@leading@TINY@d      {\habshe@calc@leading{\habshe@size@TINY@d}{-2}}
\setlength\habshe@leading@Tiny@d      {\habshe@calc@leading{\habshe@size@Tiny@d}{-3}}
\setlength\habshe@leading@tiny@d      {\habshe@calc@leading{\habshe@size@tiny@d}{-4}}
\setlength\habshe@leading@MINUSCULE@d {\habshe@calc@leading{\habshe@size@MINUSCULE@d}{-5}}
\setlength\habshe@leading@Minuscule@d {\habshe@calc@leading{\habshe@size@Minuscule@d}{-6}}
\setlength\habshe@leading@minuscule@d {\habshe@calc@leading{\habshe@size@minuscule@d}{-7}}

% System Base Leading (L)
\newdimen\habshe@leading@d
\setlength\habshe@leading@d{\habshe@leading@regular@d}

% ------------------------------------------------------------------
% 2.2 Horizontal Text Measures: Character-Width Formulas
% Character factor: w = 0.50 * Size (in pt)
% ------------------------------------------------------------------
\newdimen\habshe@bodywidth@d
\newdimen\habshe@marginwidth@d

% W_body: 65 chars of (SMALL + small) / 2
% 65 * 0.50 * (SMALL + small) / 2 = 16.25 * (SMALL + small)
\setlength\habshe@bodywidth@d{%
  \dimexpr 16.25\habshe@size@SMALL@d + 16.25\habshe@size@small@d\relax
}

% W_margin: 45 chars of Tiny
% 45 * 0.50 * Tiny = 22.5 * Tiny
\setlength\habshe@marginwidth@d{%
  \dimexpr 22.5\habshe@size@Tiny@d\relax
}

% ------------------------------------------------------------------
% 2.3 Horizontal Page Partition: Remainder & Margins
% Core Content: W_core = W_body + W_margin
% Remainder:    X = Paper - W_core
% Partition:    Left = 0.40X, Right = 0.40X, Gutter = 0.20X
% ------------------------------------------------------------------
\newdimen\habshe@remainder@X
\setlength\habshe@remainder@X{%
  \dimexpr\paperwidth - \habshe@bodywidth@d - \habshe@marginwidth@d\relax
}

\newdimen\habshe@margin@left@d
\newdimen\habshe@margin@right@d
\newdimen\habshe@gutter@d
\newdimen\habshe@fullwidth@d

\setlength\habshe@margin@left@d {\dimexpr\habshe@remainder@X * 40 / 100\relax}
\setlength\habshe@margin@right@d{\dimexpr\habshe@remainder@X * 40 / 100\relax}
\setlength\habshe@gutter@d      {\dimexpr\habshe@remainder@X * 20 / 100\relax}

% Full-width text area = Body + Gutter + Margin
\setlength\habshe@fullwidth@d{%
  \dimexpr\paperwidth - \habshe@margin@left@d - \habshe@margin@right@d\relax
}

% ------------------------------------------------------------------
% 2.4 Horizontal Static Paragraph & Inset Parameters
% ------------------------------------------------------------------
\newdimen\habshe@parindent@d
\newdimen\habshe@labelsep@d
\newdimen\habshe@leftmargini@d
\newdimen\habshe@leftmarginii@d
\newdimen\habshe@leftmarginiii@d
\newdimen\habshe@leftmarginiv@d
\newdimen\habshe@emergencystretch@d

\newskip\habshe@runinsep@s
\setlength\habshe@runinsep@s{%
  \glueexpr 0.8\habshe@size@regular@d 
  plus 0.25\habshe@size@regular@d 
  minus 0.15\habshe@size@regular@d\relax
}
\newcommand{\habshe@runinsep}{\hskip\habshe@runinsep@s\relax}


\setlength\habshe@parindent@d        {1.0\habshe@size@regular@d}
\setlength\habshe@labelsep@d         {0.5\habshe@size@regular@d}
\setlength\habshe@leftmargini@d      {2.0\habshe@size@regular@d}
\setlength\habshe@leftmarginii@d     {1.5\habshe@size@regular@d}
\setlength\habshe@leftmarginiii@d    {1.2\habshe@size@regular@d}
\setlength\habshe@leftmarginiv@d     {1.0\habshe@size@regular@d}
\setlength\habshe@emergencystretch@d {1.5\habshe@size@regular@d}

% TOC Indentations
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
\setlength\habshe@toc@indent@ii  {1.5\habshe@size@regular@d}
\setlength\habshe@toc@indent@iii {3.8\habshe@size@regular@d}
\setlength\habshe@toc@indent@iv  {7.0\habshe@size@regular@d}

\setlength\habshe@toc@numwidth@z   {2.0\habshe@size@regular@d}
\setlength\habshe@toc@numwidth@i   {2.0\habshe@size@regular@d}
\setlength\habshe@toc@numwidth@ii  {2.3\habshe@size@regular@d}
\setlength\habshe@toc@numwidth@iii {3.2\habshe@size@regular@d}
\setlength\habshe@toc@numwidth@iv  {4.1\habshe@size@regular@d}

% ------------------------------------------------------------------
% 2.5 Vertical Static Canvas & Grid Parameters
% ------------------------------------------------------------------
\newdimen\habshe@margin@top@d
\newdimen\habshe@margin@bottom@d
\newdimen\habshe@headheight@d
\newdimen\habshe@headsep@d
\newdimen\habshe@footskip@d
\newdimen\habshe@topskip@d
\newdimen\habshe@parskip@d

\setlength\habshe@margin@top@d    {5.0\habshe@leading@d}
\setlength\habshe@margin@bottom@d {6.25\habshe@leading@d}
\setlength\habshe@headheight@d    {1.0\habshe@leading@d}
\setlength\habshe@headsep@d       {1.5\habshe@leading@d}
\setlength\habshe@footskip@d      {2.5\habshe@leading@d}
\setlength\habshe@topskip@d       {1.0\habshe@leading@d}
\setlength\habshe@parskip@d       {\z@}

% ------------------------------------------------------------------
% 2.6 Vertical Dynamic Skips (Derived from Base Leading L)
% ------------------------------------------------------------------
\newskip\habshe@displayskip
\newskip\habshe@displayshortskip
\newskip\habshe@belowdisplayshortskip

\setlength\habshe@displayskip{%
  \glueexpr 1.0\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@displayshortskip{%
  \glueexpr 0.0\habshe@leading@d plus 0.2\habshe@leading@d\relax
}
\setlength\habshe@belowdisplayshortskip{%
  \glueexpr 0.5\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}

% List Skips
\newskip\habshe@list@topsep
\newskip\habshe@list@itemsep
\newskip\habshe@list@parsep
\newskip\habshe@list@topsep@ii

\setlength\habshe@list@topsep{%
  \glueexpr 0.5\habshe@leading@d plus 0.15\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@list@itemsep{%
  \glueexpr 0.25\habshe@leading@d plus 0.1\habshe@leading@d\relax
}
\setlength\habshe@list@parsep{%
  \glueexpr 0\p@ plus 0.05\habshe@leading@d\relax
}
\setlength\habshe@list@topsep@ii{%
  \glueexpr 0.25\habshe@leading@d plus 0.1\habshe@leading@d\relax
}

% Environment Skips
\newskip\habshe@topicskip
\newskip\habshe@subtopicskip

\setlength\habshe@topicskip{%
  \glueexpr 1.50\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subtopicskip{%
  \glueexpr 1.25\habshe@leading@d plus 0.2\habshe@leading@d minus 0.1\habshe@leading@d\relax
}

% Heading Skips (Negative beforeskip suppresses post-heading indent)
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
  \glueexpr -3.0\habshe@leading@d plus -0.5\habshe@leading@d minus -0.2\habshe@leading@d\relax
}
\setlength\habshe@subject@after{%
  \glueexpr 1.5\habshe@leading@d plus 0.2\habshe@leading@d\relax
}
\setlength\habshe@heading@before{%
  \glueexpr -2.5\habshe@leading@d plus -0.4\habshe@leading@d minus -0.2\habshe@leading@d\relax
}
\setlength\habshe@heading@after{%
  \glueexpr 1.2\habshe@leading@d plus 0.15\habshe@leading@d\relax
}
\setlength\habshe@subheading@before{%
  \glueexpr -2.0\habshe@leading@d plus -0.3\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subheading@after{%
  \glueexpr 1.0\habshe@leading@d plus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubheading@before{%
  \glueexpr -1.5\habshe@leading@d plus -0.2\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubheading@after{%
  \glueexpr 0.8\habshe@leading@d plus 0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubsubheading@before{%
  \glueexpr -1.2\habshe@leading@d plus -0.2\habshe@leading@d minus -0.1\habshe@leading@d\relax
}
\setlength\habshe@subsubsubheading@after{%
  \glueexpr 0.6\habshe@leading@d plus 0.1\habshe@leading@d\relax
}

% Apply Baseline Engine Parameters
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

\setlength\marginparpush{1.0\habshe@leading@d}

% ==================================================================
% 3. NFSS Typography Scale & Global Math Subscripts
% ==================================================================
\edef\habshe@num@HUGE      {\strip@pt\habshe@size@HUGE@d}
\edef\habshe@num@Huge      {\strip@pt\habshe@size@Huge@d}
\edef\habshe@num@huge      {\strip@pt\habshe@size@huge@d}
\edef\habshe@num@LARGE     {\strip@pt\habshe@size@LARGE@d}
\edef\habshe@num@Large     {\strip@pt\habshe@size@Large@d}
\edef\habshe@num@large     {\strip@pt\habshe@size@large@d}
\edef\habshe@num@regular   {\strip@pt\habshe@size@regular@d}
\edef\habshe@num@SMALL     {\strip@pt\habshe@size@SMALL@d}
\edef\habshe@num@Small     {\strip@pt\habshe@size@Small@d}
\edef\habshe@num@small     {\strip@pt\habshe@size@small@d}
\edef\habshe@num@TINY      {\strip@pt\habshe@size@TINY@d}
\edef\habshe@num@Tiny      {\strip@pt\habshe@size@Tiny@d}
\edef\habshe@num@tiny      {\strip@pt\habshe@size@tiny@d}
\edef\habshe@num@MINUSCULE {\strip@pt\habshe@size@MINUSCULE@d}
\edef\habshe@num@Minuscule {\strip@pt\habshe@size@Minuscule@d}
\edef\habshe@num@minuscule {\strip@pt\habshe@size@minuscule@d}

% Global Math Subscript Engine (Step-down: script = k-2, scriptscript = k-4)
\DeclareMathSizes{\habshe@num@HUGE}     {\habshe@num@HUGE}     {\habshe@num@huge}     {\habshe@num@Large}
\DeclareMathSizes{\habshe@num@Huge}     {\habshe@num@Huge}     {\habshe@num@LARGE}    {\habshe@num@large}
\DeclareMathSizes{\habshe@num@huge}     {\habshe@num@huge}     {\habshe@num@Large}    {\habshe@num@regular}
\DeclareMathSizes{\habshe@num@LARGE}    {\habshe@num@LARGE}    {\habshe@num@large}    {\habshe@num@SMALL}
\DeclareMathSizes{\habshe@num@Large}    {\habshe@num@Large}    {\habshe@num@regular}  {\habshe@num@Small}
\DeclareMathSizes{\habshe@num@large}    {\habshe@num@large}    {\habshe@num@SMALL}    {\habshe@num@small}
\DeclareMathSizes{\habshe@num@regular}  {\habshe@num@regular}  {\habshe@num@Small}    {\habshe@num@TINY}
\DeclareMathSizes{\habshe@num@SMALL}    {\habshe@num@SMALL}    {\habshe@num@small}    {\habshe@num@Tiny}
\DeclareMathSizes{\habshe@num@Small}    {\habshe@num@Small}    {\habshe@num@TINY}     {\habshe@num@tiny}
\DeclareMathSizes{\habshe@num@small}    {\habshe@num@small}    {\habshe@num@Tiny}     {\habshe@num@MINUSCULE}
\DeclareMathSizes{\habshe@num@TINY}     {\habshe@num@TINY}     {\habshe@num@tiny}     {\habshe@num@Minuscule}
\DeclareMathSizes{\habshe@num@Tiny}     {\habshe@num@Tiny}     {\habshe@num@MINUSCULE}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@tiny}     {\habshe@num@tiny}     {\habshe@num@Minuscule}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@MINUSCULE}{\habshe@num@MINUSCULE}{\habshe@num@minuscule}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@Minuscule}{\habshe@num@Minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}
\DeclareMathSizes{\habshe@num@minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}{\habshe@num@minuscule}

% 16-Tier NFSS Font Commands
\DeclareRobustCommand\HUGE{%
  \@setfontsize\HUGE{\habshe@num@HUGE}{\habshe@leading@HUGE@d}%
}
\DeclareRobustCommand\Huge{%
  \@setfontsize\Huge{\habshe@num@Huge}{\habshe@leading@Huge@d}%
}
\DeclareRobustCommand\huge{%
  \@setfontsize\huge{\habshe@num@huge}{\habshe@leading@huge@d}%
}
\DeclareRobustCommand\LARGE{%
  \@setfontsize\LARGE{\habshe@num@LARGE}{\habshe@leading@LARGE@d}%
}
\DeclareRobustCommand\Large{%
  \@setfontsize\Large{\habshe@num@Large}{\habshe@leading@Large@d}%
}
\DeclareRobustCommand\large{%
  \@setfontsize\large{\habshe@num@large}{\habshe@leading@large@d}%
}
\DeclareRobustCommand\normalsize{%
  \@setfontsize\normalsize{\habshe@num@regular}{\habshe@leading@regular@d}%
  \abovedisplayskip\habshe@displayskip
  \belowdisplayskip\habshe@displayskip
  \abovedisplayshortskip\habshe@displayshortskip
  \belowdisplayshortskip\habshe@belowdisplayshortskip
  \let\@listi\@listI
}
\normalsize
\let\regular\normalsize

\DeclareRobustCommand\SMALL{%
  \@setfontsize\SMALL{\habshe@num@SMALL}{\habshe@leading@SMALL@d}%
}
\DeclareRobustCommand\Small{%
  \@setfontsize\Small{\habshe@num@Small}{\habshe@leading@Small@d}%
}
\DeclareRobustCommand\small{%
  \@setfontsize\small{\habshe@num@small}{\habshe@leading@small@d}%
}
\DeclareRobustCommand\TINY{%
  \@setfontsize\TINY{\habshe@num@TINY}{\habshe@leading@TINY@d}%
}
\DeclareRobustCommand\Tiny{%
  \@setfontsize\Tiny{\habshe@num@Tiny}{\habshe@leading@Tiny@d}%
}
\DeclareRobustCommand\tiny{%
  \@setfontsize\tiny{\habshe@num@tiny}{\habshe@leading@tiny@d}%
}
\DeclareRobustCommand\MINUSCULE{%
  \@setfontsize\MINUSCULE{\habshe@num@MINUSCULE}{\habshe@leading@MINUSCULE@d}%
}
\DeclareRobustCommand\Minuscule{%
  \@setfontsize\Minuscule{\habshe@num@Minuscule}{\habshe@leading@Minuscule@d}%
}
\DeclareRobustCommand\minuscule{%
  \@setfontsize\minuscule{\habshe@num@minuscule}{\habshe@leading@minuscule@d}%
}

% Compatibility Aliases for Standard Packages
\let\footnotesize\Small
\let\scriptsize\TINY

% List Engine Hooks
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

% ==================================================================
% 4. Page Geometry Initialization (Piggyback Solver)
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

% Margin note formatting
\renewcommand*\@marginparreset{%
  \reset@font\TINY
  \raggedright
  \slshape
}

% ==================================================================
% 5. Layout Streams: Full-Width and Tufte
% ==================================================================
% State Encoding: 0 = Full-Width, 1 = Tufte
\chardef\habshe@layout@state=0

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

% Scoped layout environments
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

% Backward-compatible shorthands
\newcommand{\fullwidth}{\setlayoutfullwidth}
\newcommand{\tufte}{\setlayouttufte}

% Sidenote guard: Suppressed in Full-Width layout
\let\habshe@orig@marginpar\marginpar
\renewcommand{\marginpar}[2][]{%
  \ifcase\habshe@layout@state
    % State 0: Full-Width
    \ClassWarning{habshe-tufte}{%
      \string\marginpar\space omitted: illegal in full-width layout%
    }%
  \or
    % State 1: Tufte
    \if\relax\detokenize{#1}\relax
      \habshe@orig@marginpar{#2}%
    \else
      \habshe@orig@marginpar[#1]{#2}%
    \fi
  \fi
}

% Start in Full-Width layout stream
\AtBeginDocument{\setlayoutfullwidth}

% ==================================================================
% 6. Custom Sectioning Architecture (Full-Width Headings)
% ==================================================================
\setcounter{secnumdepth}{0}

\newcounter{subject}
\newcounter{heading}[subject]
\newcounter{subheading}[heading]
\newcounter{subsubheading}[subheading]
\newcounter{subsubsubheading}[subsubheading]

% Prevent heading text leaking into running headers or body
\let\subjectmark\@gobble
\let\headingmark\@gobble
\let\subheadingmark\@gobble
\let\subsubheadingmark\@gobble
\let\subsubsubheadingmark\@gobble

% Table of Contents hooks using matrix indent dimensions
\newcommand*\l@subject{\@dottedtocline{1}{\habshe@toc@indent@z}{\habshe@toc@numwidth@z}}
\newcommand*\l@heading{\@dottedtocline{2}{\habshe@toc@indent@i}{\habshe@toc@numwidth@i}}
\newcommand*\l@subheading{\@dottedtocline{3}{\habshe@toc@indent@ii}{\habshe@toc@numwidth@ii}}
\newcommand*\l@subsubheading{\@dottedtocline{4}{\habshe@toc@indent@iii}{\habshe@toc@numwidth@iii}}
\newcommand*\l@subsubsubheading{\@dottedtocline{5}{\habshe@toc@indent@iv}{\habshe@toc@numwidth@iv}}

% Heading wrapper to ensure full-width span across margins
\newcommand{\habshe@heading@format}[2]{%
  \par
  \begingroup
  \setlength\hsize{\habshe@fullwidth@d}%
  \setlength\linewidth{\habshe@fullwidth@d}%
  #1#2\par
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
% 7. Topic & Subtopic Environments
% ==================================================================
% Topic: Regular bold run-in, SMALL body, unindented first line
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

% Subtopic: Small bold run-in, small body, indented first line
\newenvironment{subtopic}[1][]{%
  \par
  \addvspace{\habshe@subtopicskip}%
  \begingroup
  \indent
  \if\relax\detokenize{#1}\relax\else
    {\SMALL\bfseries #1\habshe@runinsep}%
  \fi
  \SMALL\normalfont
  \ignorespaces
}{%
  \par
  \endgroup
  \addvspace{\habshe@subtopicskip}%
}

\endinput
