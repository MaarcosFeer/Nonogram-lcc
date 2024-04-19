:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).
:-use_module(library(clpfd)).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	
	nth0(RowN, RowsClues, ActualRowClues),
	satisfiedLine(ActualRowClues,NewRow,RowSat).

	transpose(NewGrid,Transpose).
	%nth0(ColN,NewGrid,Col),
	%nth0(ColN, ColsClues, ActualColClues),
	%satisfiedLine(ActualColClues,Col,ColSat). 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CB: 1 sola pista
satisfiedLine([C|[]],Line,IsSatisfied):- satisfiedClue(C,Line,IsSatisfied,_).

%CR: mas de 1 pista
satisfiedLine([HC|Clues],Line,IsSatisfied):-
    satisfiedClue(HC,Line,IsSatisfied,RestOfLine),
    satisfiedLine(Clues,RestOfLine,IsSatisfied).

satisfiedLine(_,_,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% 1 = TRUE, 0 = FALSE
%La cantidad de celdas que faltan pintar es mayor a lo que queda por recorrer de la lista
satisfiedClue(N,Line,0,_):-
    length(Line, Length),
    N > Length.

%Se encontraron exactamente N celdas pintadas consecutivas
satisfiedClue(N,Line,1,RestOfLine):-
    nConsecutive(N,Line,RestOfLine).

%Estoy en una celda vacia    
satisfiedClue(N,[H|T],IsSatisfied,RestOfLine):-
    H \== "#",
    satisfiedClue(N,T,IsSatisfied,RestOfLine).

%No encontre exactamente N celdas consecutivas pintadas, me muevo a la celda vacia mas cercana
satisfiedClue(N,[H|T],IsSatisfied,RestOfLine):-
	H == "#",
    not(nConsecutive(N,[H|T],_)),
    moveToNextEmpty(T,Tm),
    satisfiedClue(N,Tm,IsSatisfied,RestOfLine).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CB: No se necesitan pintar mas celdas.
%nConsecutive(Number,ActualList,RestOfList).
nConsecutive(0,[],[]).
nConsecutive(0,[H|T],[H|T]):- H \== "#".
%CR 
nConsecutive(N,[H|T],Ts):-
	H == "#",
    Nr is N -1,
    nConsecutive(Nr,T,Ts). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CB: no estoy en un '#'
moveToNextEmpty([],[]).
moveToNextEmpty([H|T],[H|T]):- H \== "#".
%CR
moveToNextEmpty([H|T],Ts):- 
	H == "#",
	moveToNextEmpty(T,Ts).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%