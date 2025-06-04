%% arxiv-preprint.cls
%% A sophisticated LaTeX document class for dual-target academic publishing
%% Optimized for both journal submissions and arXiv preprints
%% Author: Joel Saucedo
%% Version: 1.0
%% Date: 2025-06-04

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{arxiv-preprint}[2025/06/04 v1.0 Dual-target academic manuscript class]

%% Class options
\newif\if@arxivmode
\newif\if@journalmode
\newif\if@draftmode
\newif\if@twoside
\newif\if@onecolumn
\newif\if@twocolumn

%% Default values
\@arxivmodefalse
\@journalmodefalse
\@draftmodefalse
\@twosidefalse
\@onecolumntrue
\@twocolumnfalse

%% Option declarations
\DeclareOption{arxiv}{\@arxivmodetrue\@journalmodefalse}
\DeclareOption{journal}{\@journalmodetrue\@arxivmodefalse}
\DeclareOption{draft}{\@draftmodetrue}
\DeclareOption{final}{\@draftmodefalse}
\DeclareOption{oneside}{\@twosidefalse}
\DeclareOption{twoside}{\@twosidetrue}
\DeclareOption{onecolumn}{\@onecolumntrue\@twocolumnfalse}
\DeclareOption{twocolumn}{\@twocolumnfalse\@onecolumntrue}

%% Pass remaining options to article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

%% Default option
\ExecuteOptions{arxiv,final,oneside,onecolumn}
\ProcessOptions\relax

%% Load base class
\if@arxivmode
    \LoadClass[11pt,letterpaper]{article}
\else
    \LoadClass[10pt,a4paper,twoside]{article}
\fi

%% Required packages
\RequirePackage{ifpdf}
\RequirePackage{amsmath,amssymb,amsfonts}
\RequirePackage{amsthm}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{url}
\RequirePackage{hyperref}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{titlesec}
\RequirePackage{abstract}
\RequirePackage{authblk}
\RequirePackage{lineno}
\RequirePackage{setspace}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{float}
\RequirePackage{booktabs}
\RequirePackage{natbib}

%% Conditional packages
\if@arxivmode
    \RequirePackage[colorlinks=true,linkcolor=blue,citecolor=blue,urlcolor=blue]{hyperref}
\else
    \RequirePackage[colorlinks=false,pdfborder={0 0 0}]{hyperref}
\fi

%% Page geometry
\if@arxivmode
    \geometry{
        letterpaper,
        margin=1in,
        top=1.2in,
        bottom=1.2in,
        headheight=14pt,
        headsep=0.25in,
        footskip=0.3in
    }
\else
    \geometry{
        a4paper,
        margin=0.75in,
        top=1in,
        bottom=1in,
        headheight=12pt,
        headsep=0.2in,
        footskip=0.25in
    }
\fi

%% Smart figure management
\newcommand{\maxfigwidth}{0.8\textwidth}
\if@arxivmode
    \graphicspath{{figures/compressed/}}
    \renewcommand{\maxfigwidth}{0.9\textwidth}
\else
    \graphicspath{{figures/high-res/}}
    \renewcommand{\maxfigwidth}{0.7\textwidth}
\fi

%% Enhanced cross-referencing commands
\newcommand{\figref}[1]{Figure~\ref{#1}}
\newcommand{\tabref}[1]{Table~\ref{#1}}
\newcommand{\eqref}[1]{Equation~(\ref{#1})}
\newcommand{\secref}[1]{Section~\ref{#1}}
\newcommand{\appref}[1]{Appendix~\ref{#1}}

%% Conditional content commands
\newcommand{\journalonly}[1]{\if@journalmode#1\fi}
\newcommand{\arxivonly}[1]{\if@arxivmode#1\fi}
\newcommand{\draftonly}[1]{\if@draftmode#1\fi}

%% Draft mode features
\if@draftmode
    % Line numbering
    \RequirePackage{lineno}
    \linenumbers
    \setlength\linenumbersep{3pt}
    \renewcommand\linenumberfont{\normalfont\scriptsize\sffamily\color{gray}}
    
    % Draft watermark
    \RequirePackage{draftwatermark}
    \SetWatermarkText{DRAFT}
    \SetWatermarkScale{0.8}
    \SetWatermarkColor[gray]{0.9}
    
    % Enhanced headers for drafts
    \pagestyle{fancy}
    \fancyhf{}
    \fancyhead[L]{\small\textsc{Draft - \today}}
    \fancyhead[R]{\small Page \thepage}
    \renewcommand{\headrulewidth}{0.4pt}
\fi

%% Figure paths - intelligent switching
\if@arxivmode
    \graphicspath{{figures/compressed/}{figures/}}
    \newcommand{\maxfigwidth}{0.9\textwidth}
    \newcommand{\maxfigheight}{0.8\textheight}
\else
    \graphicspath{{figures/high-res/}{figures/}}
    \newcommand{\maxfigwidth}{0.7\textwidth}
    \newcommand{\maxfigheight}{0.6\textheight}
\fi

%% Typography and spacing
\if@arxivmode
    \setlength{\columnsep}{0.2in}
    \setlength{\parindent}{1.5em}
    \setlength{\parskip}{0.1em}
    \renewcommand{\baselinestretch}{1.2}
\else
    \setlength{\columnsep}{0.25in}
    \setlength{\parindent}{1em}
    \setlength{\parskip}{0em}
    \renewcommand{\baselinestretch}{1.15}
\fi

%% Font configuration
\if@arxivmode
    % Computer Modern for arXiv (widely supported)
    \renewcommand{\rmdefault}{cmr}
    \renewcommand{\sfdefault}{cmss}
    \renewcommand{\ttdefault}{cmtt}
\else
    % Times for journal (professional appearance)
    \RequirePackage{mathptmx}
    \RequirePackage[scaled=0.9]{helvet}
    \RequirePackage{courier}
\fi

%% Header and footer configuration
\pagestyle{fancy}
\fancyhf{} % Clear all header and footer fields

\if@arxivmode
    \if@draftmode
        \fancyhead[L]{\small\textsc{Draft Manuscript}}
        \fancyhead[R]{\small\today}
        \fancyfoot[C]{\small arXiv Preprint - Page \thepage}
        \fancyfoot[R]{\small\texttt{\jobname}}
    \else
        \fancyhead[L]{}
        \fancyhead[R]{}
        \fancyfoot[C]{\thepage}
    \fi
\else
    \if@twoside
        \fancyhead[LE,RO]{\thepage}
        \fancyhead[LO]{\small\rightmark}
        \fancyhead[RE]{\small\leftmark}
    \else
        \fancyhead[L]{\small\leftmark}
        \fancyhead[R]{\thepage}
    \fi
\fi

\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

%% Section formatting
\if@arxivmode
    \titleformat{\section}
        {\Large\bfseries}
        {\thesection.}
        {0.5em}
        {}
    \titleformat{\subsection}
        {\large\bfseries}
        {\thesubsection.}
        {0.5em}
        {}
    \titleformat{\subsubsection}
        {\normalsize\bfseries}
        {\thesubsubsection.}
        {0.5em}
        {}
\else
    \titleformat{\section}
        {\large\bfseries}
        {\thesection.}
        {0.5em}
        {}
    \titleformat{\subsection}
        {\normalsize\bfseries}
        {\thesubsection.}
        {0.5em}
        {}
    \titleformat{\subsubsection}
        {\normalsize\itshape}
        {\thesubsubsection.}
        {0.5em}
        {}
\fi

%% Abstract formatting
\if@arxivmode
    \renewcommand{\abstractname}{\large\bfseries Abstract}
    \renewenvironment{abstract}
        {\quotation\noindent\abstractname\par\medskip\noindent}
        {\endquotation}
\fi

%% Theorem environments
\newtheoremstyle{arxivtheorem}
    {0.5em}   % Space above
    {0.5em}   % Space below
    {\itshape} % Body font
    {}        % Indent amount
    {\bfseries} % Theorem head font
    {.}       % Punctuation after theorem head
    {0.5em}   % Space after theorem head
    {}        % Theorem head spec

\newtheoremstyle{journaltheorem}
    {0.3em}   % Space above
    {0.3em}   % Space below
    {\itshape} % Body font
    {}        % Indent amount
    {\bfseries} % Theorem head font
    {.}       % Punctuation after theorem head
    {0.3em}   % Space after theorem head
    {}        % Theorem head spec

\if@arxivmode
    \theoremstyle{arxivtheorem}
\else
    \theoremstyle{journaltheorem}
\fi

\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{example}[theorem]{Example}

%% Enhanced figure and table captions
\if@arxivmode
    \captionsetup{
        font={small,sf},
        labelfont=bf,
        labelsep=period,
        justification=centering,
        margin=1em
    }
\else
    \captionsetup{
        font={footnotesize,sf},
        labelfont=bf,
        labelsep=period,
        justification=justified,
        margin=0.5em
    }
\fi

%% Bibliography configuration
\if@arxivmode
    \bibpunct{[}{]}{,}{n}{}{,}
    \renewcommand{\cite}[1]{\citep{#1}}
\else
    \bibpunct{(}{)}{,}{a}{}{,}
\fi

%% Line numbering for drafts
\if@draftmode
    \RequirePackage{lineno}
    \linenumbers
    \renewcommand\linenumberfont{\normalfont\tiny\sffamily\color{gray}}
\fi

%% Conditional content commands
\newcommand{\journalonly}[1]{\if@journalmode#1\fi}
\newcommand{\arxivonly}[1]{\if@arxivmode#1\fi}
\newcommand{\draftonly}[1]{\if@draftmode#1\fi}
\newcommand{\finalonly}[1]{\if@draftmode\else#1\fi}

%% Enhanced math environments
\newcommand{\abs}[1]{\left|#1\right|}
\newcommand{\norm}[1]{\left\|#1\right\|}
\newcommand{\set}[1]{\left\{#1\right\}}
\newcommand{\paren}[1]{\left(#1\right)}
\newcommand{\bracket}[1]{\left[#1\right]}
\newcommand{\ceil}[1]{\left\lceil#1\right\rceil}
\newcommand{\floor}[1]{\left\lfloor#1\right\rfloor}

%% Units and constants
\newcommand{\unit}[1]{\,\mathrm{#1}}
\newcommand{\const}[1]{\mathrm{#1}}

%% Cross-referencing enhancements
\if@arxivmode
    \newcommand{\figref}[1]{\hyperref[#1]{Figure~\ref*{#1}}}
    \newcommand{\tabref}[1]{\hyperref[#1]{Table~\ref*{#1}}}
    \newcommand{\eqref}[1]{\hyperref[#1]{Equation~(\ref*{#1})}}
    \newcommand{\secref}[1]{\hyperref[#1]{Section~\ref*{#1}}}
\else
    \newcommand{\figref}[1]{Figure~\ref{#1}}
    \newcommand{\tabref}[1]{Table~\ref{#1}}
    \renewcommand{\eqref}[1]{Equation~(\ref{#1})}
    \newcommand{\secref}[1]{Section~\ref{#1}}
\fi

%% Title page enhancements
\if@arxivmode
    \renewcommand{\maketitle}{%
        \begin{center}%
            {\LARGE\bfseries\@title\par}%
            \vskip 1.5em%
            {\large\@author\par}%
            \vskip 1em%
            {\large\@date\par}%
        \end{center}%
        \vskip 2em%
    }
\fi

%% Watermark for drafts
\if@draftmode
    \RequirePackage{draftwatermark}
    \SetWatermarkText{DRAFT}
    \SetWatermarkScale{0.8}
    \SetWatermarkColor[gray]{0.9}
\fi

%% Table of contents customization
\if@arxivmode
    \renewcommand{\contentsname}{\large\bfseries Contents}
    \setcounter{tocdepth}{2}
\fi

%% Appendix handling
\RequirePackage{appendix}
\if@arxivmode
    \renewcommand{\appendixname}{Appendix}
    \renewcommand{\appendixtocname}{Appendices}
    \renewcommand{\appendixpagename}{Appendices}
\fi

%% Enhanced equation numbering
\numberwithin{equation}{section}
\numberwithin{figure}{section}
\numberwithin{table}{section}

%% End of class file
\endinput
