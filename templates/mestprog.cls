% This is a template for programming courses test
% Author: trifon

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% General setup %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{mestprog}[2018/02/04 v0.9.5 MEST programming template]

% setup fonts and encodings
\RequirePackage[T2A]{fontenc}
\RequirePackage{ucs}
\RequirePackage[utf8x]{inputenc}
\RequirePackage[english,bulgarian]{babel}



% support for A5 format
\DeclareOption{a5paper}{
  \PassOptionsToClass{\CurrentOption}{report}
  \PassOptionsToPackage{left=1cm,top=1cm,right=1cm,bottom=1cm,nohead,foot=0.5cm}{geometry}
}

% support for A4 format
\DeclareOption{a4paper}{
  \PassOptionsToClass{\CurrentOption}{report}
  \PassOptionsToPackage{left=2cm,top=2.5cm,right=2cm,bottom=1.5cm,nohead,nofoot}{geometry}
}

% void pts command will ignore any points settings unless option pts is selected
\newcommand{\pts}[1]{}

% setup MEST footer
% #1 = time
% #2 = !!note!!
\newcommand{\mestfooter}[2]{
  Време за работа: #1 минути.
  \footnote{#2}
}

% support for points
\DeclareOption{pts}{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Points calculation %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% setup point calculation
\AtEndOfClass{\RequirePackage{fp}}

% convert from internal to external points (divide by 10)
\newcommand{\topts}[1]{\FPeval{\result}{clip(#1/10)}\result}

% set points for a question
\renewcommand{\pts}[1]{\textbf{(\topts{#1} т.)}\addtocounter{points}{#1}}

% setup points counter
\newcounter{points}
\setcounter{points}{0}

% default point value for closed questions
\newcommand{\defaultpts}{15}

% setup MEST footer with points
% #1 = minimum points
% #2 = maximum points
% #3 = time
% #4 = !!note!!
\renewcommand{\mestfooter}[4]{
  Необходим минимум: #1 точки.\\
  Признават се максимум: #2 точки.\\
  Постижим максимум: \topts{\arabic{points}} точки.\\
  Време за работа: #3 минути.
  \footnote{#4}
}
}

% pass all unknown options to the base report class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}

% set defaults
\ExecuteOptions{a5paper}

% use user-defined options
\ProcessOptions

% load base class
\LoadClass[10pt]{report}

% setup page geometry
\RequirePackage{geometry}

% setup source code listings
% default language is C++
\RequirePackage{listings}
\lstset{
	inputencoding=utf8x,
	extendedchars=\true,
	basicstyle=\small\ttfamily,
	keywordstyle=\color{blue!50!black},
	commentstyle=\color{gray},
	tabsize=4,
	showstringspaces=false,
	language=C++,
	backgroundcolor=\color{white},
	frame=shadowbox,
	framerule=1pt,
	rulesepcolor=\color{gray}
}


% for importing images
\RequirePackage{graphicx}

% setup watermark
\RequirePackage{eso-pic}
\newcommand{\mestwatermark}[1]{
  \ClearShipoutPicture
  \AddToShipoutPicture{\includegraphics[width=1.8cm,height=1.8cm]{#1}}
}
\newcommand{\mestbackground}[1]{
\AddToShipoutPicture{\includegraphics[width=\paperwidth,height=\paperheight]{#1}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Various shortcuts %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open question spaces
\newcommand{\shortspace}{4.5cm}
\newcommand{\mediumspace}{5.5cm}

% shortcut for fixed-size font
\renewcommand{\tt}{\texttt}

% shortcut for 5x5 matrix to be filled by the student
\newcommand{\charmatrix}{
  \begin{minipage}{0.35\textwidth}
    \begin{center}
      \begin{tabular}{|c|c|c|c|c|}
        \hline &&&&\\
        \hline &&&&\\
        \hline &&&&\\
        \hline &&&&\\
        \hline &&&&\\
        \hline
      \end{tabular}
    \end{center}
  \end{minipage}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% MEST commands %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WARNING: MESTgen recognizes them only when used in the begginning of a line!

% test environment
\newenvironment{test}
	{\begin{enumerate}}
	{\end{enumerate}}

% use this command to start a new question
\newcommand{\startQuestion}{%
	\item%
}

% use this command to finalized a closed question
% mil0: you may want endQuestion, but it wont work :)
\newcommand{\finishQuestion}{%
	\end{enumerate}%
}

% use this command to start enumerating answers
\newcommand{\answers}{%
\begin{enumerate}%
\setlength{\topsep}{-2mm}%
\setlength{\itemsep}{0mm}%
}

% a new open question. Specify spacing as an optional argument
\newcommand{\openQuestion}[2][2cm]{%
\startQuestion%
#2%
\vspace*{#1}%
}

% a shortcut for a closed question
% first argument is the question text
% second argument are the question answers
\newcommand{\question}[2]{%
\startQuestion%
\pts{\defaultpts} #1%
\answers%
	#2%
\finishQuestion%
}

% bogus commands for denoting question groups
\newcommand{\startAlternatives}{\item \begin{enumerate}}
\newcommand{\finishAlternatives}{\end{enumerate}}

% commands for wrong and correct answers (in the template)
\newcommand{\wrong}{\item}
\newcommand{\correct}{\item(+) }

% commands for wrong and correct answers (in the output)
\newcommand{\postCorrect}{\item}
\newcommand{\postWrong}{\item}

% setup answer table
\newcommand{\ts}[1][]{\makebox[4mm]{#1}}
\newcommand{\columnFormat}{|@{}c@{}}
\newcommand{\tableExtra}{}

% setup MEST header
% #1 = course title
% #2 = course subtitle
% #3 = date
% #4 = !!variant!!
% #5 = !!spacing!!
% #6 = !!numbers!!
% #7 = !!boxes!!
% #8 = \tableExtra
\newcommand{\mestheader}[8]{
  % define a comment environment
  \newif\ifmestgen
  \mestgenfalse
  \begin{center}
    {\Large\textbf{#1}\\
      \textit{#2}} %the name of the course

    Тест --- #3 % the name/date of the test

    Вариант #4 % which variant will be present

    % the information to be filled from the student
    Трите имена: \hrulefill\hspace{1ex} Ф№ \rule{2.5cm}{.1pt}\\

    \ifmestgen
    % the table to fill answers
    % table will be included only if TeX file built under mestgen
    \begin{tabular}{#5|}
      \hline
      &#6\\
      \hline
      #8
      \hline
      #4#7\\
      \hline
    \end{tabular}
    \fi
  \end{center}

  % setup spacing
  \setlength{\parindent}{0mm}
  \setlength{\parskip}{0cm}
  \setlength{\baselineskip}{3mm}
  \setlength{\itemsep}{-1cm}
}
