:- module(proylcc,
	[  
		put/8
	]).
:-dynamic(trySolveGrid/1).
:-use_module(library(lists)).
:-use_module(library(clpfd)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).
replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
	XIndex > 0, XIndexS is XIndex - 1, 
	replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%
put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).

	replace(Row, RowN, NewRow, Grid, NewGrid), % NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	
	(
		replace(Cell, ColN, _, Row, NewRow), Cell == Content;
		replace(_Cell, ColN, Content, Row, NewRow)), 
	nth0(RowN, RowsClues, ActualRowClues), %Chequeo si se cumplen las pistas de la fila actual
	
	satisfiedLine(ActualRowClues, NewRow, RowSat), 
	transpose(NewGrid, TransposeNewGrid), 
	nth0(ColN, TransposeNewGrid, Col), 
	nth0(ColN, ColsClues, ActualColClues), %Chequeo si se cumplen las pistas de la columna actual
	
	satisfiedLine(ActualColClues, Col, ColSat). 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% satisfiedLine(+Clues, +Line, -IsSatisfied).
%IsSatisfied: 1 = TRUE, 0 = FALSE
%CB: Sin pistas(Mismo efecto que pista 0), me fijo que el resto de la línea esté sin pintar
satisfiedLine([], Line, IsSatisfied):-
	cleanLine(Line, IsSatisfied).

%CR: mas de 1 pista: chequeo pista actual y paso a la siguiente
satisfiedLine([HC|Clues], Line, IsSatisfied):-
	satisfiedClue(HC, Line, IsSatisfied, RestOfLine), 
	satisfiedLine(Clues, RestOfLine, IsSatisfied).

%Entra en este caso y devuelve falso si no pudo satsifacer niguno de los anteriores
satisfiedLine(_,_,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% satisfiedClue(+Clue, +Line, -IsSatisfied, -RestOfLine).
%Caso pista 0
satisfiedClue(0,Line,1,Line).
%La cantidad de celdas que faltan pintar es mayor a lo que queda por recorrer de la lista
satisfiedClue(N, Line, 0, Line):-
	length(Line, Length), N > Length.

%Estoy en una celda sin pintar, sigo recorriendo    
satisfiedClue(N, [H|T], IsSatisfied, RestOfLine):-
	H \== "#", 
	satisfiedClue(N, T, IsSatisfied, RestOfLine).

%Se encontraron exáctamente N celdas pintadas consecutivas
satisfiedClue(N, Line, 1, RestOfLine):-
	nConsecutive(N, Line, RestOfLine).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nConsecutive(+RequiredCells, +Line, -RestOfLine).

%CB: No se necesitan pintar mas celdas.
nConsecutive(0,[],[]).
nConsecutive(0, [H|T], [H|T]):-
	H \== "#".
%CR 
nConsecutive(N, [H|T], Ts):-
	H == "#", Nr is N - 1, 
	nConsecutive(Nr, T, Ts). 
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cleanLine(+Line, -IsClean).

%Devuelve 1 si la línea está limpia (no tiene ninguna celda pintada), de lo contrario devuelve 0
cleanLine([],1).
cleanLine([H|_], 0):-
	H == "#".
cleanLine([H|T], IsClean):-
	H \== "#", 
	cleanLine(T, IsClean).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkWin(+SatisfiedRowClues, +SatisfiedColClues, -IsAWin).
%Si todas las pistas de las filas y columnas son 1 (están satisfechas) estoy en condiciones de ganar
checkWin([],[],true).
checkWin(SatisfiedRowClues, SatisfiedColClues, true):-
	forall(
		member(RowClue, SatisfiedRowClues), 1 is RowClue), 
	forall(
		member(ColClue, SatisfiedColClues), 1 is ColClue).
checkWin(_,_,false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initClues(+Grid,+RowsClues, +ColsClues,-NewSatisfiedRowClues,-NewSatisfiedColClues).
%Inicializa el chequeo de todas las pistas.
initClues(Grid, RowsClues, ColsClues, NewSatisfiedRowClues, NewSatisfiedColClues):-
	initCluesAux(Grid, RowsClues, NewSatisfiedRowClues), 
	transpose(Grid, TransposeGrid), 
	initCluesAux(TransposeGrid, ColsClues, NewSatisfiedColClues). 

%initCluesAux(+Grid,+LineClues,-NewSatisfiedLineClues).	
initCluesAux([],_,[]).
%CB 1 sola linea por recorrer
initCluesAux([Line|[]], [ActualLineClues|[]], [IsSatisfied]):-
	satisfiedLine(ActualLineClues, Line, IsSatisfied).
%CR: más de 1 línea por recorrer
initCluesAux([Line|RestOfLine], [ActualLineClues|RestOfClues], [IsSatisfied|RestOfSatisfied]):-
	satisfiedLine(ActualLineClues, Line, IsSatisfied), 
	initCluesAux(RestOfLine, RestOfClues, RestOfSatisfied).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solveGame(RowClues,ColClues,Grid,SolvedGrid):-
transpose(Grid,TransposeGrid),
paintInitialCols(ColClues,TransposeGrid,NewTransposeGrid),
transpose(NewTransposeGrid,NewGrid),
trySolveGrid(RowClues,ColClues,NewGrid,SolvedGrid).

trySolveGrid(RowClues,ColClues,Grid,SolvedGrid):-
trySolveRows(RowClues,Grid,SolvedGrid),
transpose(SolvedGrid,TSolvedGrid),
checkCols(ColClues,TSolvedGrid).

%trySolveRows(RowClues,Grid,sSolvedGrid)
trySolveRows([C|_],[R|_],[S]):-
solveLine(C,R,S).

trySolveRows([C|Cs],[R|Rs],[S|Ss]):-
solveLine(C,R,S),
trySolveRows(Cs,Rs,Ss).

%checkCols(Clues,Grid)
checkCols([C|[]],[L|[]]):-
satisfiedLine(C,L,IsSatisfied),
IsSatisfied == 1.

checkCols([C|Cs],[L|Ls]):-
satisfiedLine(C,L,IsSatisfied),
IsSatisfied == 1,
checkCols(Cs,Ls).

%Pinto las columnas que tienen una unica posible solucion.
%paintInitialCols(ColClues,Grid,NewGrid)
paintInitialCols([],[],[]).

paintInitialCols([C|Cs],[L|Ls],[SolvedL|Ns]):-
length(L,Length),
oneSolve(C,Length),
solveLine(C,L,SolvedL),
paintInitialCols(Cs,Ls,Ns),!.

paintInitialCols([_|Cs],[L|Ls],[L|Ns]):-
paintInitialCols(Cs,Ls,Ns).

%solveLine(Clues,Line,NewLine)
solveLine([],Line,NewLine):-
fillWithCross(Line,NewLine).

solveLine([C|Cs],Line,NewLine):-
trySolveClue(C,0,Line,RestOfLine,L),
solveLine(Cs,RestOfLine,Ls),
append(L,Ls,NewLine).

%trySolveClue(+C,+Gap,+Line,-RestOfLine,-NewLine)
trySolveClue(C,Gap,Line,RestOfLine,NewLine):-
solveClue(C,Gap,Line,RestOfLine,NewLine).

trySolveClue(C,Gap,Line,RestOfLine,NewLine):-
NewGap is Gap+1,
length(Line,Length),
N is NewGap+C,
N =< Length,
trySolveClue(C,NewGap,Line,RestOfLine,NewLine).

%solveClue(+C,+Gap,+Line,-RestOfLine,-NewLine)
solveClue(C,0,Line,RestOfLine,NewLine):-
paintClue(C,Line,RestOfLine,NewLine).

solveClue(C,Gap,[H|T],RestOfLine,["X"|L]):-
H \== "#",
Gr is Gap-1,
solveClue(C,Gr,T,RestOfLine,L).

%paintClue(Clue,Line,RestOfLine,NewLine).
paintClue(0,[],[],[]).

paintClue(0,[H|T],T,["X"]):- H \== "#".

paintClue(Clue,[H|T],RestOfLine,["#"|L]):-
Clue > 0,
H \== "X",
RC is Clue -1,
paintClue(RC,T,RestOfLine,L).

oneSolve([],_).
oneSolve(Clues,LineLength):-
getSum(Clues,Sum),
LineLength is Sum-1.

getSum([C|[]],S):- S is C+1.

getSum([C|Cs],Sum):-
getSum(Cs,R),
Sum is C+1+R.

%fillWithCross(Line,NewLine)
fillWithCross([],[]).
fillWithCross([H|T],["X"|Ns]):-
	H \== "#",
	fillWithCross(T,Ns).