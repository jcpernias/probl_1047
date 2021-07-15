%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{probl}[2018/10/15 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}
\newbool{answers}
\newbool{toc}

\booltrue{toc}
\boolfalse{answers}

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}
\DeclareOption{noanswers}{\boolfalse{answers}}
\DeclareOption{answers}{\booltrue{answers}}
\DeclareOption{notoc}{\boolfalse{toc}}
\ExecuteOptions{es, noanswers, notoc}
\ProcessOptions\relax

%% Class loading
%% --------------------------------------------------------------------------------
\LoadClassWithOptions{article}
\RequirePackage{moresize}


%% Load packages
%% --------------------------------------------------------------------------------
\RequirePackage{docs-base}
\RequirePackage{docs-pages}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-lists}
\RequirePackage{docs-units}
\RequirePackage{docs-tables}
\RequirePackage{docs-hyper}
\RequirePackage{docs-cclic}
\RequirePackage{docs-answers}

%% Floats
%% --------------------------------------------------------------------------------

% \usepackage{float}
\usepackage{caption}
\usepackage{floatrow}
\floatsetup[table]{style=plaintop}
\floatsetup[figure]{style=plaintop}
\captionsetup{labelsep=endash,labelfont=bf,font=sl,
  position=above,singlelinecheck=no}
\captionsetup[subfloat]{labelsep=space,labelfont={rm, up},
  justification=centering}


%% Bombs
%% --------------------------------------------------------------------------------
\RequirePackage{fourier-orns}

\newcommand*{\DANGER}{\raisebox{3pt}{\large\bomb}\quad}
\newcommand*{\DDANGER}{\raisebox{2pt}{\large\bomb\,\bomb}\quad}

%% Listings
%% --------------------------------------------------------------------------------
% \RequirePackage{minted}
% \tcbuselibrary{minted}
% \renewcommand{\DeleteFile}[2][]{}
% \newtcblisting{Rminted}{%
%   colback = SourceCodeFill,
%   colframe = SourceCodeFrame,
%   boxrule = 0pt,
%   listing only,%
%   minted language=r}

% \RequirePackage{newfloat}
% \usemintedstyle{xcode}

% \tcolorboxenvironment{verbatim}{%
%   sharp corners = all,
%   boxrule = 0.25pt,
%   colframe = ROutputFrame,
%   colback = ROutputFill
% }


%% TOC
%% -----------------------------------------------------------------

\RequirePackage{titletoc}
\contentsmargin{2pc}
\titlecontents{section}[0pc]
{\addvspace{1ex}\sffamily\bfseries}
{\contentslabel{2pc}}
{}
{\hfill\contentspage}



%% Title
%% --------------------------------------------------------------------------------

\RequirePackage{titling}

\pretitle{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
\posttitle{\par\end{flushleft}}

\preauthor{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
\postauthor{\par\end{flushleft}}

\predate{\begin{flushleft}\Large\sffamily\bfseries\color{Title}}
\postdate{\par\end{flushleft}}



\AtBeginDocument{%
  \color{MainText}
  \pagenumbering{roman}
  \let\oldmaketitle\maketitle
  \renewcommand{\maketitle}{%
    \oldmaketitle%
    \ifbool{toc}{\tableofcontents}{}%
    \thispagestyle{empty}%
    \cleardoublepage{}%
    \ccpage%
    \pagenumbering{arabic}
    \oldmaketitle
    \let\maketitle\oldmaketitle%
  }
  \maketitle
}



%% Section headings
%% -----------------------------------------------------------------
\RequirePackage[%
newparttoc,%
clearempty,%
pagestyles,%
outermarks,%
nobottomtitles*,%
compact]{titlesec}

% \RequirePackage[pagestyles, outermarks, nobottomtitles*, compact]{titlesec}

\deftranslation[to=Spanish]{Exercise}{Ejercicio}
\deftranslation[to=English]{Exercise}{Exercise}
\newcommand*{\ExerciseName}{\translate{Exercise}}

\newcommand*{\eat}[1]{}
\titleformat{name=\section}[hang]
{\normalfont\large\bfseries\sffamily}
{\color{Section}\ExerciseName\ \thesection}{0em}{\eat}

\titlespacing*{name=\section}{0pt}{*3.5}{*0.75}


% \titleformat{name=\section}[hang]{%
%   \color{Section}\Large\sffamily\bfseries}{%
%   \makebox[1.25cm][l]{\thesection.}}{0pt}{}

% \titlespacing*{name=\section}{-1.25cm}{*7}{*1.5}
% \titleformat{name=\section, numberless}
% {\color{Section}\Large\sffamily\bfseries}
% {}{0pt}{}

% \titlespacing*{name=\section, numberless}{0pc}{*7}{*1.5}

\titleformat{\subsection}
{\color{Subsection}\large\sffamily\bfseries}
{\makebox[1cm][l]{\thesubsection.}}{0.3cm}{}


\titlespacing*{\subsection}{0pt}{*3.5}{*1.5}

%% Add space between exercises
\setlist[1]{itemsep=\baselineskip}


\ifbool{langES}{%
  \setlist[enumerate,2]{label = \emph{\alph*})}
  }{}
\ifbool{langEN}{%
  \setlist[enumerate,2]{label = (\alph*)}
  }{}
