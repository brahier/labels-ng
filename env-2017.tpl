\documentclass[12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[french,english]{babel}
\usepackage{thumbpdf}
\usepackage[
  pdftex
]{hyperref} 
\usepackage{t1enc}
% \renewcommand*{\rmdefault}{bop}\rmfamily
% \renewcommand*{\ttdefault}{mgm}\rmfamily
\usepackage{palatino}
\usepackage{layout}
\usepackage{vmargin}
\usepackage{graphicx}
\setpapersize[landscape]{C6} % 114 x 162
%\setpapersize[landscape]{B6} %  125 x 176
%             left  top   right bottom headH headsep footH footSkip
\setmarginsrb{10mm}{10mm}{10mm}{10mm}{0pt}{0mm}{0pt}{0mm}
\setlength{\parindent}{0mm}
\pagestyle{empty}
\sloppy
\begin{document}
\selectlanguage{french}
[% FOREACH epr = list -%]
% LOG [% epr.no %] [% epr.prix %] [% epr.max %]
[% i = 1 -%]
[% WHILE i <= epr.max -%] 
\vspace*{\fill}
\begin{minipage}[t]{34mm}
\vspace*{\fill}
\includegraphics [width=30mm] {logo.jpg}
\end{minipage}
\begin{minipage}[t]{107mm}
\begin{center}
[% INCLUDE body %]

{\Huge
\bf [% i %][% IF i < 2 %]er[% ELSE %]ème[% END %] rang
}
\medskip

{Informations sur Internet: \begin{otherlanguage}{english}{www.brahier.ch}\end{otherlanguage}}
\end{center}
\end{minipage}
\clearpage
[% i = i + 1 -%]
[% END -%]
[% i = 1 -%]
[% WHILE i <= epr.spare -%] 
\vspace*{\fill}
\begin{minipage}[t]{34mm}
\vspace*{\fill}
\includegraphics [width=30mm] {logo.jpg}
\end{minipage}
\begin{minipage}[t]{107mm}
\begin{center}
[% INCLUDE body %]

{\Huge
\bf \hspace*{1cm}ème rang
}
\medskip

{Informations sur Internet: \begin{otherlanguage}{english}{www.brahier.ch}\end{otherlanguage}}
\end{center}
\end{minipage}
\clearpage
[% i = i + 1 -%]
[% END -%]
[% END -%]
\end{document}
[% BLOCK body %]
{\Huge
Corminboeuf -- 2017
}
\bigskip

[% IF epr.no != '' %]
{\Large
Epreuve [% epr.no %], [% epr.cat %]
}
\bigskip
[% END %]
{\Large
[% epr.prix FILTER latex %]\\
\vspace*{2mm}
[% epr.lieu FILTER latex %]
}
[% IF epr.note %]
\vspace*{2mm}
{\em [% epr.note FILTER latex %]}
[% END %]
\bigskip

[% END %]

