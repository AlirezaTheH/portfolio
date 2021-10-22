\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{altacv}[Custom AltaCV]

% Choice of round/square photo
\newif\if@normalphoto
\DeclareOption{normalphoto}{\@normalphototrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\newif\if@raggedtwoe
\DeclareOption{ragged2e}{\@raggedtwoetrue}

% Load hyperref for clickable hyperlinks
\newif\if@withhyper
\DeclareOption{withhyper}{\@withhypertrue}
\ProcessOptions\relax

\LoadClass{article}

% Hopefully this helps make the PDF file more 'friendly' with
% copy-paste etc
\RequirePackage{etoolbox}
\RequirePackage[a-1b]{pdfx}
\RequirePackage{accsupp}
\RequirePackage[margin=2cm]{geometry}
\RequirePackage[fixed]{fontawesome5}
\RequirePackage{ifxetex,ifluatex}
\RequirePackage{scrlfile}
\RequirePackage{xparse}

% Added for convenience
\newif\ifxetexorluatex
\ifxetex
    \xetexorluatextrue
\else
    \ifluatex
        \xetexorluatextrue
    \else
        \xetexorluatexfalse
    \fi
\fi

\ifxetexorluatex
    \RequirePackage{fontspec}
\else
    % Attempts to make ligatures copy-paste as normal characters
    \RequirePackage{cmap}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage[T1]{fontenc}
    \input{glyphtounicode}
    \pdfglyphtounicode{f_f}{FB00}
    \pdfglyphtounicode{f_f_i}{FB03}
    \pdfglyphtounicode{f_f_l}{FB04}
    \pdfglyphtounicode{f_i}{FB01}
    \pdfgentounicode=1
\fi

\if@raggedtwoe
    \RequirePackage[newcommands]{ragged2e}
\fi

\if@withhyper
    \AtBeginDocument{%
        \hypersetup{hidelinks}
        \urlstyle{same}
    }
\fi


% Colors
\RequirePackage{xcolor}

\definecolor{themecolor}{HTML}{5c2f7e}
\definecolor{slategray}{HTML}{2e2e2e}
\definecolor{lightergray}{HTML}{e9e9e9}
\definecolor{lightgray}{HTML}{666666}

\colorlet{sidecolor}{lightergray}
\colorlet{accent}{themecolor}
\colorlet{emphasis}{slategray}
\colorlet{heading}{themecolor}
\colorlet{headingrule}{themecolor}
\colorlet{subheading}{emphasis}
\colorlet{body}{lightgray}
\colorlet{name}{emphasis}
\colorlet{tagline}{emphasis}

% Required packages and settings
\RequirePackage{tikz}
\usetikzlibrary{arrows}
\RequirePackage[skins]{tcolorbox}
\RequirePackage[inline]{enumitem}
\setlist{
    leftmargin=*,
    labelsep=0.5em,
    nosep,itemsep=0.25\baselineskip,
    after=\vspace{0.25\baselineskip}
}
\newcommand{\itemmarker}{{\small\textbullet}}
\setlist[itemize]{label=\itemmarker}
% Make fonts of itemize environments slightly smaller
\AtBeginEnvironment{itemize}{\small}
\RequirePackage{graphicx}
\RequirePackage{trimclip}
\RequirePackage{dashrule}
\RequirePackage{multirow,tabularx}
\RequirePackage{changepage}

\setlength{\parindent}{0pt}
\newcommand{\divider}{\textcolor{body!40}{\hdashrule{\linewidth}{0.6pt}{0.5ex}}\medskip}

\newenvironment{fullwidth}{%
  \begin{adjustwidth}{}{\dimexpr-\marginparwidth-\marginparsep\relax}}{\end{adjustwidth}
}

% \detokenize will break UTF-8 in pdflatex
\newcommand{\utffriendlydetokenize}[1]{%
\scantokens{%
    \catcode`\_=12%
%    \catcode`\^=12%
%    \catcode`\{=12%
%    \catcode`\}=12%
    \catcode`\&=12%
    \catcode`\$=12%
    \catcode`\#=12%
    \catcode`\~=12%
    \catcode`\%=12%
%    \catcode`\\=12%
    {#1}%
}%
}

% Incorporating hyperlinks
% Using \unfriendlydetokenize to avoid breaking unicode
% Use accsupp so that when copying/pasting the icon from PDF to a text
% file, the icon name is pasted
% \printinfo{symbol}{detail}[optional hyperlink prefix]
\ExplSyntaxOn
\NewDocumentCommand{\printinfo}{m m o}{%
    \BeginAccSupp{method=escape,ActualText={#1:~#2}}
    \IfNoValueTF{#3}{%
        \mbox{\textcolor{accent}{\normalfont #1}~\utffriendlydetokenize{#2}\hspace{2em}}%
    }{%
        \if@withhyper%
            \mbox{\textcolor{accent}{\normalfont #1}~
            \href{#3}{\utffriendlydetokenize{#2}}\hspace{2em}}
        \else%
            \ClassWarning{Please specify [withhyper] option to enable hyperlinks. %
                         Printing out full hyperlink prefix #1 for now.}%
            \mbox{\textcolor{accent}{\normalfont #1}~{\utffriendlydetokenize{#3#2}}\hspace{2em}}%
        \fi%
    }%
    \EndAccSupp{}
}%


% Exploring convenient creation of fields
% Add starred mode to create \printinfo with full URL
% \NewInfoFiled{fieldname}{symbol}[optional hyperlink prefix]
% \NewInfoFiled*{fieldname}{symbol}
\NewDocumentCommand{\NewInfoField}{s m m o}{%
    \IfBooleanF{#1}{
        \IfNoValueF{#4}{\csdef{#2 hyperprefix}{#4}}%
    }
    \csdef{#2 symbol}{#3}%
    \IfBooleanTF{#1}{%
        \csdef{#2}##1##2{%
            \if@withhyper
                \IfNoValueTF{##2}
                    {\printinfo{\csuse{#2 symbol}}{##1}}%
                    {\printinfo{\csuse{#2 symbol}}{##1}[##2]}%
            \else
                \printinfo{\csuse{#2 symbol}}{##1}%
            \fi%
        }%
    }{%
        \csdef{#2}##1{%
            \if@withhyper
                \IfNoValueTF {#4}
                    {\printinfo{\csuse{#2 symbol}}{##1}}%
                    {\printinfo{\csuse{#2 symbol}}{##1}[\csuse{#2 hyperprefix}##1]}%
            \else
                \printinfo{\csuse{#2 symbol}}{##1}%
            \fi%
        }%
    }
}
\ExplSyntaxOff

\newcommand{\firstname}[1]{\def\@firstname{#1}}
\newcommand{\lastname}[1]{\def\@lastname{#1}}
\newcommand{\tagline}[1]{\def\@tagline{#1}}
\newcommand{\contact}[1]{\def\@contact{#1}}
\NewInfoField*{portfolio}{\faGlobe}
\NewInfoField{birthdate}{\faBirthdayCake}
\NewInfoField*{email}{\faAt}
\NewInfoField*{phone}{\faPhone}
\NewInfoField*{linkedin}{\faLinkedinIn}
\NewInfoField*{github}{\faGithub}
\NewInfoField*{location}{\faMapMarker}

% Support for multiple photos
\newlength{\altacv@photos@width}
\newlength{\altacv@photo@diam@left}
\newlength{\altacv@photo@diam@right}
\def\altacv@left@photos{}
\def\altacv@right@photos{}

\newcommand{\@makeaphoto}[2]{%
    \begin{minipage}{#1}%
        \if@normalphoto
            \includegraphics[width=\linewidth]{#2}
        \else
            \tikz\path[fill overzoom image={#2}]circle[radius=0.5\linewidth];
        \fi%
    \end{minipage}%
}

\newcommand{\altacv@add@photo@left}[1]{%
    \appto{\altacv@left@photos}{%
        \@makeaphoto{\altacv@photo@diam@left}{#1}\hspace{1ex}%
    }%
    \addtolength{\altacv@photos@width}{\altacv@photo@diam@left}%
    \addtolength{\altacv@photos@width}{1ex}%
}
\newcommand{\altacv@add@photo@right}[1]{%
    \appto{\altacv@right@photos}{%
        \@makeaphoto{\altacv@photo@diam@right}{#1}\hspace{1ex}%
    }%
    \addtolength{\altacv@photos@width}{\altacv@photo@diam@right}%
    \addtolength{\altacv@photos@width}{1ex}%
}
\newcommand{\photoL}[2]{%
    \setlength{\altacv@photo@diam@left}{#1}%
    \forcsvlist{\altacv@add@photo@left}{#2}%
}
\newcommand{\photoR}[2]{%
    \setlength{\altacv@photo@diam@right}{#1}%
    \forcsvlist{\altacv@add@photo@right}{#2}%
}
\let\photo\photoL

% Fonts
\newcommand{\namefontshared}{\fontsize{30}{60}\selectfont}
\newcommand{\firstnamefont}{\namefontshared\fontseries{l}\selectfont}
\newcommand{\lastnamefont}{\namefontshared\fontseries{mb}\selectfont}
\newcommand{\taglinefont}{\large\fontseries{mb}\selectfont}
\newcommand{\contactfont}{\footnotesize\bfseries}
\newcommand{\cvsectionfontshared}{\large}
\newcommand{\cvsectionfont}{\cvsectionfontshared\bfseries}
\newcommand{\cvsectionlightfont}{\cvsectionfontshared}
\newcommand{\cvsubsectionfont}{\fontsize{11}{11}\selectfont\bfseries}
\newcommand{\cvsubsubsectionfont}{\bfseries}


\RequirePackage{calc}

% Column calculations
\def\@left{.5cm}
\def\@right{.5cm}
\def\@columnsep{1cm}
\def\@columnratio{.25}
\def\@sidecolwidth{\dimexpr\@columnratio\dimexpr\pdfpagewidth-\@left-\@right-\@columnsep\relax}
\def\@sidewidth{\dimexpr\@sidecolwidth+\@left+.5\@columnsep}
\geometry{left=\@left,right=\@right,top=1cm,bottom=1cm,columnsep=\@columnsep}

% Side background color
\RequirePackage{eso-pic}

\AddToShipoutPictureBG{%
    \AtPageLowerLeft{%
        \color{sidecolor}%
        \rule
            {\@sidewidth}
            {\dimexpr\pdfpageheight}%
    }
}

\newcommand{\makecvheader}{%
    \setcolumnwidth{\@sidecolwidth/1cm,8cm/1cm}
    \begin{paracol}{3}
        \begin{column}
            \vspace*{-.75cm}
            \altacv@left@photos\centering%
        \end{column}
        \begin{column}
        \begingroup
            \vspace*{.5cm}
            \raggedright%
            {\firstnamefont\color{name}\@firstname\lastnamefont\color{name}\@lastname\par}
            \medskip
            {\color{tagline}\taglinefont\@tagline\par}
        \endgroup\medskip
        \end{column}
        \begin{column}
            \vspace*{.5cm}
            {\contactfont\@contact\par}
            \altacv@right@photos\par%
        \end{column}
    \end{paracol}
}

\renewenvironment{quote}{\color{accent}\itshape\large}{\par}

% \cvsection{light title}{title}
\newcommand{\cvsection}[2]{%
  \nointerlineskip\bigskip%
  \ifstrequal{#1}{}{}{{\color{heading}\cvsectionlightfont#1\hspace{.05cm}}}%
  {\color{heading}\cvsectionfont#2}\\[-1ex]%
  {\color{headingrule}\rule{\linewidth}{.1pt}\par}\medskip
}

% \cvsubsection{title}
\newcommand{\cvsubsection}[1]{%
  {\color{subheading}\cvsubsectionfont{#1}\par}\smallskip
}

% \cvsubsubsection{title}
\newcommand{\cvsubsubsection}[1]{%
  {\cvsubsubsectionfont{#1}\par}\smallskip
}


% \cvevent{title}{company or school}{timeperiod}{location}
\newcommand{\cvevent}[5]{%
  {\cvsubsectionfont\color{emphasis}#1\par}
  \smallskip\normalsize
  \ifstrequal{#2}{}{}{
      \textbf{#2}
      \ifstrequal{#3}{}{\par\smallskip}{}
  }
  \ifstrequal{#3}{}{}{{#3}\par\smallskip}
  \ifstrequal{#4}{}{}{{\small\makebox[0.5\linewidth][l]{\faCalendar~#4}}}%
  \ifstrequal{#5}{}{}{{\small\makebox[0.5\linewidth][l]{\faMapMarker~#5}}}\par
  \medskip\normalsize
}

% \cvachievement{symbol}{title}{detail}
\newcommand{\cvachievement}[3]{%
  \begin{tabularx}{\linewidth}{@{}p{2em} @{\hspace{1ex}} >{\raggedright\arraybackslash}X@{}}
  \multirow{2}{*}{\Large\color{accent}#1} & \bfseries\textcolor{emphasis}{#2}\\
  & #3
  \end{tabularx}%
  \smallskip
}


\newlength{\badgewidth}
% \cvbadges{comma-separated list of badges}
\newcommand{\cvbadges}[1]{%
    % Varibale for saving total badge width in current line
    \pgfmathsetmacro{\sofarlinewidth}{0}%
    \foreach \badgetext in {#1} {%
        % Calculate badgewidth with length of badgetext + 2*(inner xsep)
        \settowidth{\badgewidth}{\pgfinterruptpicture\footnotesize\badgetext\endpgfinterruptpicture+8}%
        % Check if badge is too large for current line
        \ifdimgreater{\badgewidth}{\linewidth-\sofarlinewidth}{%
            % Go to next line
            \par%
            \pgfmathparse{0}%
            \global\let\sofarlinewidth=\pgfmathresult%
        }%
        {%
            % Add badgewidth + node distance
            \pgfmathparse{\sofarlinewidth+\badgewidth+2}%
            \global\let\sofarlinewidth=\pgfmathresult%
        }%
        \tikz[baseline]\node[
            anchor=base,
            draw=body!40,
            rounded corners,
            inner xsep=4pt,
            inner ysep =0.75ex,
            text height=1.5ex,
            text depth=.25ex,
            font=\footnotesize]{\badgetext};
    }
}


\newcommand{\ratingmarker}{\faCircle}

% Use accsupp so that the actual numeric value is copied/pasted
% \cvskill{title}{rate}
\newcommand{\cvskill}[2]{%
  \textcolor{emphasis}{\textbf{#1}}\hfill
  \BeginAccSupp{method=plain,ActualText={#2}}
  \foreach \x in {1,...,5}{%
    \ifdimequal{\x pt - #2 pt}{0.5pt}%
    {\clipbox*{0pt -0.25ex {.5\width} {\totalheight}}{\color{accent}\ratingmarker}%
     \clipbox*{{.5\width} -0.25ex {\width} {\totalheight}}{\color{body!30}\ratingmarker}}
    {\ifdimgreater{\x bp}{#2 bp}{\color{body!30}}{\color{accent}}\ratingmarker}%
  }\EndAccSupp{}\par%
}

% \wheelchart{outer radius}{inner radius}{
% comma-separated list of value/text width/color/detail}
\newcommand{\wheelchart}[4][0]{%
    \begingroup\centering
    \def\innerradius{#3}%
    \def\outerradius{#2}%
    % Calculate total
    \pgfmathsetmacro{\totalnum}{0}%
    \foreach \value/\colour/\name in {#4} {%
        \pgfmathparse{\value+\totalnum}%
        \global\let\totalnum=\pgfmathresult%
    }%
    \begin{tikzpicture}

        % Calculate the thickness and the middle line of the wheel
        \pgfmathsetmacro{\wheelwidth}{\outerradius-\innerradius}
        \pgfmathsetmacro{\midradius}{(\outerradius+\innerradius)/2}
        \pgfmathsetmacro{\totalrot}{-90 + #1}

        % Rotate so we start from the top
        \begin{scope}[rotate=\totalrot]

        % Loop through each value set. \cumnum keeps track of where we are in the wheel
        \pgfmathsetmacro{\cumnum}{0}
        \foreach \value/\width/\colour/\name in {#4} {
            \pgfmathsetmacro{\newcumnum}{\cumnum + \value/\totalnum*360}

            % Calculate the percent value
            \pgfmathsetmacro{\percentage}{\value/\totalnum*100}
            % Calculate the mid angle of the colour segments to place the labels
            \pgfmathsetmacro{\midangle}{-(\cumnum+\newcumnum)/2}

            % This is necessary for the labels to align nicely
            \pgfmathparse{
                (-\midangle>180?"west":"east")
            } \edef\textanchor{\pgfmathresult}
            \pgfmathparse{
                (-\midangle>180?"flush left":"flush right")
            } \edef\textalign{\pgfmathresult}
            \pgfmathsetmacro\labelshiftdir{1-2*(-\midangle<180)}

            % Draw the color segments. Somehow, the \midrow units got lost, so we add 'pt' at the end. Not nice...
            \filldraw[draw=white,fill=\colour]
            (-\cumnum:\outerradius) arc (-\cumnum:-(\newcumnum):\outerradius)
            -- (-\newcumnum:\innerradius) arc (-\newcumnum:-(\cumnum):\innerradius)
            -- cycle;

            % Draw the data labels
            % Use accsupp so that the numeric number is copied/pasted too
            \draw  [*-,thin,emphasis] node [append after command={(\midangle:\midradius pt)
            -- (\midangle:\outerradius + 1ex)
            -- (\tikzlastnode)}] at (\midangle:\outerradius + 1ex) [xshift=\labelshiftdir*0.5cm,
                                                                    inner sep=1ex,
                                                                    outer sep=0pt,
                                                                    text width=\width,
                                                                    anchor=\textanchor,
                                                                    align=\textalign,
                                                                    font=\small,text=body]
                {\BeginAccSupp{
                    method=pdfstringdef,ActualText={\name: \value}}\name
                \EndAccSupp{}};
            % Set the old cumulated angle to the new value
            \global\let\cumnum=\newcumnum
        }
        \end{scope}
        %      \draw[gray] (0,0) circle (\outerradius) circle (\innerradius);
    \end{tikzpicture}\par
    \endgroup
}

% \cvref{name}{institute}{email}
\newcommand{\cvref}[3]{%
  \smallskip
  \textcolor{emphasis}{\textbf{#1}}\par
  \begin{description}[font=\color{accent},style=multiline,leftmargin=1.35em,align=left]
  \item[\small\normalfont\emailsymbol] #2
  \item[\small\normalfont\mailaddresssymbol] #3
  \end{description}
%   \medskip
}

\newenvironment{cvcolumn}[1]{\begin{minipage}[t]{#1}\raggedright}{\end{minipage}}


% Make it easier to add a sidebar aligned with top of next page
\RequirePackage{afterpage}
\newcommand{\addsidebar}[2][]{\marginpar{%
    \ifstrequal{#1}{}{}{\vspace*{#1}}%
    \input{#2}}%
}
\newcommand{\addnextpagesidebar}[2][]{\afterpage{\addsidebar[#1]{#2}}}


\AtBeginDocument{%
  \pagestyle{empty}
  \color{body}
  \raggedright
}
