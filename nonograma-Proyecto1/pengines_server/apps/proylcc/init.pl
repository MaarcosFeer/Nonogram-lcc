 :- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[0,1,2],[1,1],[5],[0],[],[5],[0],[1,2,0]],	% RowsClues

[[0],[1],[2],[1],[1],[1],[1,0,2]], 	% ColsClues

[["#", _ , _ ,"X", _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"],
["#", _ , _ , _ , _ , _ ,"X"]]
).
 	
 	
