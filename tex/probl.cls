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

\InputIfFileExists{probl.cfg}{}{}

%% Class loading
%% --------------------------------------------------------------------------------
\LoadClassWithOptions{article}

%% More font sizes
%% --------------------------------------------------------------------------------
\RequirePackage{moresize}


%% Load packages
%% --------------------------------------------------------------------------------
\RequirePackage{docs-full}
\RequirePackage{docs-pages}


%% Answers
%% --------------------------------------------------------------------------------
\RequirePackage{verbatim}   % for the comment environment

\tcbuselibrary{breakable, skins}


\colorlet{AnswerFrame}{CourseColor!65!Black}
\colorlet{AnswerFill}{White}

\ifbool{answers}{%
  \newtcolorbox{answer}{coltext=MainText, colframe=AnswerFrame,%
    colback=AnswerFill,%
    notitle, boxrule=0.25pt,%
    fontupper=\small, breakable, skin=enhanced, parbox=false,%
    before upper=\csname @totalleftmargin\endcsname0pt}}{%
  \newenvironment{answer}{\expandafter\comment}{\expandafter\endcomment}}

\ifbool{answers}{%
  \newcommand*{\ClearPage}{\clearpage}}{%
  \newcommand*{\ClearPage}{\relax}}


%% Lists
%% --------------------------------------------------------------------------------
\RequirePackage{enumitem}

\setlist{nosep}
\setlist[1]{leftmargin=*}
\setlist[itemize,1]{label=\textbullet}
\setlist[itemize,2]{label=-}

%% Add space between exercises
%\setlist[1]{itemsep=\baselineskip}

\ifbool{langES}{%
  \setlist[enumerate,1]{label = \emph{\alph*})}
}{}
\ifbool{langEN}{%
  \setlist[enumerate,1]{label = (\alph*)}
}{}


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

\newcommand*{\DANGER}{\makebox[0in][r]{%
    \color{Section}\raisebox{2pt}{\Large\bomb}\quad}}
\newcommand*{\DDANGER}{\makebox[0in][r]{%
    \color{Section}\raisebox{2pt}{\Large\bomb\,\bomb}\quad}}

%% Listings
%% --------------------------------------------------------------------------------
% \colorlet{SourceCodeFill}{White}
% \colorlet{SourceCodeFrame}{White}
% \colorlet{ROutputFill}{Black!15}
% \colorlet{ROutputFrame}{Black!15}
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

% \RequirePackage{titling}

% \pretitle{\begin{flushleft}\HUGE\sffamily\bfseries\color{Title}}
% \posttitle{\par\end{flushleft}}

% \preauthor{\begin{flushleft}\huge\sffamily\bfseries\color{Title}}
% \postauthor{\par\end{flushleft}}

% \predate{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
% \postdate{\par\end{flushleft}}


%% Compose frontmatter
%% --------------------------------------------------------------------------------
\AtBeginDocument{%
  \color{MainText}
  \pagenumbering{roman}
  \let\oldmaketitle\maketitle
  \renewcommand{\maketitle}{%
    \oldmaketitle%
    \ifbool{toc}{\tableofcontents}{}%
    \thispagestyle{empty}%
    \newpage{}%
    \ccpage%
    \hypersetup{pageanchor=true}
    \pagenumbering{arabic}
    \oldmaketitle
    \thispagestyle{first}
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

%% Page headers and footers
%% -----------------------------------------------------------------

\newpagestyle{problems}[\color{Section}\small\bfseries\sffamily]{%
  \renewcommand{\makeheadrule}{%
    \color{Section}\rule{\linewidth}{1.2pt}}
  \renewcommand{\makefootrule}{%
    \color{Section}\rule[0.8\baselineskip]{\linewidth}{1.2pt}}
  \sethead{}{}{}
  \setfoot*{}{}{\thepage}
}

\newpagestyle{first}[\color{Section}\small\bfseries\sffamily]{%
  \renewcommand{\makefootrule}{%
    \color{Section}\rule[0.8\baselineskip]{\linewidth}{1.2pt}}
  \sethead{}{}{}
  \setfoot*{}{}{\thepage}
}

\widenhead*{0.8cm}{4.5cm}
\pagestyle{problems}
