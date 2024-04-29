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
	
	%Chequeo si se cumplen las pistas de la fila actual
	nth0(RowN, RowsClues, ActualRowClues),
	satisfiedLine(ActualRowClues,NewRow,RowSat),

	%Chequeo si se cumplen las pistas de la columna actual
	transpose(NewGrid,TransposeNewGrid),
	nth0(ColN,TransposeNewGrid,Col),
	nth0(ColN, ColsClues, ActualColClues),
	satisfiedLine(ActualColClues,Col,ColSat). 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CB: 1 sola pista, me fijo que le resto de la línea esté sin pintar
satisfiedLine([C|[]],Line,IsSatisfied):- 
	satisfiedClue(C,Line,IsSatisfied,RestOfLine),
	cleanLine(RestOfLine,IsClean),
	IsSatisfied == IsClean.

%CR: mas de 1 pista
satisfiedLine([HC|Clues],Line,IsSatisfied):-
    satisfiedClue(HC,Line,IsSatisfied,RestOfLine),
    satisfiedLine(Clues,RestOfLine,IsSatisfied).

satisfiedLine(_,_,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%IsSatisfied: 1 = TRUE, 0 = FALSE
%CASOS CON PISTA 0
%Hay alguna celda pintada y la pista es 0, devuelvo 0.
satisfiedClue(0,[H|T],0,[H|T]):- H == "#".
%Llegué a la última celda y no está pintada, y la pista es 0, devuelvo 1.
satisfiedClue(0,[H|[]],1,[]):- H \== "#".
%La pista es 0, la celda actual no está pintada, sigo recorriendo.
satisfiedClue(0,[H|T],IsSatisfied,Ts):-
	H \== "#",
	satisfiedClue(0,T,IsSatisfied,Ts).

%CASOS CON PISTA N > 0
%La cantidad de celdas que faltan pintar es mayor a lo que queda por recorrer de la lista
satisfiedClue(N,Line,0,Line):-
    length(Line, Length),
    N > Length.

%Estoy en una celda sin pintar, sigo recorriendo    
satisfiedClue(N,[H|T],IsSatisfied,RestOfLine):-
	H \== "#",
	satisfiedClue(N,T,IsSatisfied,RestOfLine).

%Se encontraron exactamente N celdas pintadas consecutivas
satisfiedClue(N,Line,1,RestOfLine):-
    nConsecutive(N,Line,RestOfLine).

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
%Devuelve 1 la línea está limpia (no tiene ninguna celda pintada), de lo contrario devuelve 0
cleanLine([],1).
cleanLine([H|_],0):- H == "#".
cleanLine([H|T],IsClean):-
	H \== "#",
	cleanLine(T,IsClean).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	checkWin([],[],true).
checkWin(SatisfiedRowClues,SatisfiedColClues,true):- 
	forall(member(RowClue,SatisfiedRowClues), 1 is RowClue),
	forall(member(ColClue,SatisfiedColClues), 1 is ColClue).
checkWin(_,_,false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initClues(Grid,RowsClues, ColsClues,NewSatisfiedRowClues,NewSatisfiedColClues):-
	initCluesAux(Grid,RowsClues,NewSatisfiedRowClues),
	transpose(Grid,TransposeGrid),
	initCluesAux(TransposeGrid,ColsClues,NewSatisfiedColClues). 
	
	initCluesAux([],_,[]).
%CB 1 sola linea por recorrer
initCluesAux([Line|[]],[ActualLineClues|[]],[IsSatisfied]):-
	satisfiedLine(ActualLineClues,Line,IsSatisfied).

initCluesAux([Line|RestOfLine],[ActualLineClues|RestOfClues],[IsSatisfied|RestOfSatisfied]):-
	satisfiedLine(ActualLineClues,Line,IsSatisfied),
	initCluesAux(RestOfLine,RestOfClues,RestOfSatisfied).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEADCODE 

%No encontre exactamente N celdas consecutivas pintadas, me muevo a la celda vacia mas cercana
/* satisfiedClue(N,[H|T],IsSatisfied,RestOfLine):-
	H == "#",
	not(nConsecutive(N,[H|T],_)),
	moveToNextEmpty(T,Tm),
	satisfiedClue(N,Tm,IsSatisfied,RestOfLine). */

	%CB: no estoy en un '#'
	/* moveToNextEmpty([],[]).
	moveToNextEmpty([H|T],[H|T]):- H \== "#".
	%CR
	moveToNextEmpty([H|T],Ts):- 
	H == "#",
	moveToNextEmpty(T,Ts). */