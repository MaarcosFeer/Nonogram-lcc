 :- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[1,1]],	% RowsClues

[[1], [0], [1], [0], [0]], 	% ColsClues

[["#", _ ,"#" , _ , _ ]]
).
 	
 	
