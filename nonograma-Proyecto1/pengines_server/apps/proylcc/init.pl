 :- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[2,1],[1,1],[5],[3,1],[8],[2],[3,4],[1,6],[2,2,2],[1,1,1,1],[14,0],[0,2,1]],	% RowsClues

[[0],[1],[2],[1],[1],[3],[0],[0],[1],[2],[1],[1],[3],[3,2,0]], 	% ColsClues

[["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _],
["#", _ ,"#" , _ , _ , _ , _ ,"#", _ ,"#" , _ , _ , _ , _]]
).
 	
 	
