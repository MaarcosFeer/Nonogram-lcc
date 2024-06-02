 :- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[4],[8],[10],[1,1,2,1,1],[1,1,2,1,1],[1,6,1],[6],[2,2],[4],[2]],	% RowsClues

[[4],[2],[7],[3,4],[7,2],[7,2],[3,4],[7],[2],[4]], 	% ColsClues

[[_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_],
 ["#","X","#","X","#","#","X","#","X","#"],
 [_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"X",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_],
 [_,_,_,_,"#",_,_,_,_,_]
]
).