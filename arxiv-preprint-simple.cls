%% arxiv-preprint-simple.cls
%% Simple, robust document class for academic manuscripts
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{arxiv-preprint-simple}[2025/06/04 v1.0 Simple academic manuscript class]

%% Class options
\newif\if@arxivmode
\newif\if@journalmode
\newif\if@draftmode

%% Default values
\@arxivmodefalse
\@journalmodefalse
\@draftmodefalse

%% Option declarations
\DeclareOption{arxiv}{\@arxivmodetrue\@journalmodefalse}
\DeclareOption{journal}{\@journalmodetrue\@arxivmodefalse}
\DeclareOption{draft}{\@draftmodetrue}
\DeclareOption{final}{\@draftmodefalse}

%% Pass remaining options to article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

%% Default option
\ExecuteOptions{arxiv,final}
\ProcessOptions\relax

%% Load base class
\LoadClass[11pt]{article}

%% Essential packages only
\RequirePackage{amsmath,amsfonts,amssymb}
\RequirePackage{amsthm}
\RequirePackage{graphicx}
\RequirePackage{hyperref}

%% Load fancyhdr for headers/footers (needed by journal config)
\RequirePackage{fancyhdr}

%% Algorithm support (with fallback)
\IfFileExists{algorithm.sty}{
    \RequirePackage{algorithm}
    \RequirePackage{algorithmic}
}{
    % Minimal algorithm environment fallback
    \newenvironment{algorithm}[1][htbp]
      {\begin{figure}[#1]\centering}
      {\end{figure}}
    \newenvironment{algorithmic}
      {\begin{quote}\small\ttfamily\renewcommand{\\}{\par\noindent}}
      {\end{quote}}
    \newcommand{\REQUIRE}{\textbf{Require: }}
    \newcommand{\ENSURE}{\textbf{Ensure: }}
    \newcommand{\STATE}{\par\noindent\hspace*{1em}}
    \newcommand{\FOR}[1]{\par\noindent\textbf{for} #1 \textbf{do}}
    \newcommand{\ENDFOR}{\par\noindent\textbf{end for}}
    \newcommand{\IF}[1]{\par\noindent\textbf{if} #1 \textbf{then}}
    \newcommand{\ENDIF}{\par\noindent\textbf{end if}}
    \newcommand{\RETURN}{\par\noindent\textbf{return} }
}

%% Theorem environments
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{assumption}[theorem]{Assumption}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{example}[theorem]{Example}

%% Enhanced math commands
\providecommand{\argmin}{\mathop{\mathrm{argmin}}}
\providecommand{\argmax}{\mathop{\mathrm{argmax}}}

%% Simple conditional commands
\providecommand{\arxivonly}[1]{\if@arxivmode#1\fi}
\providecommand{\journalonly}[1]{\if@journalmode#1\fi}
\providecommand{\draftonly}[1]{\if@draftmode#1\fi}

\endinput
