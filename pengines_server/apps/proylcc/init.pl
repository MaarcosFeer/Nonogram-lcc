 :- module(init, [ init/3 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
    [[3,3],[5,5],[7,3,2],[12,1],[12,1],[12,2],[15],[13],[13],[11],[9],[7],[5],[3],[1]],	% RowsClues

    [[5],[8],[10],[11],[12],[12],[12],[12],[12],[12],[12],[2,8],[2,4],[2,4],[5]], 	% ColsClues 
    
    [
    [_,_,"#","#","#",_,_,_,_,_,"#","#","#",_,_],
    [_,"#",_,_,_,"#",_,_,_,"#",_,_,_,"#",_],
    ["#",_,_,_,_,_,"#",_,"#",_,_,_,_,_,"#"],
    ["#",_,_,_,_,_,_,"#",_,_,_,_,_,_,"#"],
    ["#",_,_,_,_,_,_,_,_,_,_,_,_,_,"#"],
    ["#",_,_,_,_,_,_,_,_,_,_,_,_,_,"#"],
    ["#",_,_,_,_,_,_,_,_,_,_,_,_,_,"#"],
    [_,"#",_,_,_,_,_,_,_,_,_,_,_,"#",_],
    [_,"#",_,_,_,_,_,_,_,_,_,_,_,"#",_],
    [_,_,"#",_,_,_,_,_,_,_,_,_,"#",_,_],
    [_,_,_,"#",_,_,_,_,_,_,_,"#",_,_,_],
    [_,_,_,_,"#",_,_,_,_,_,"#",_,_,_,_],
    [_,_,_,_,_,"#",_,_,_,"#",_,_,_,_,_],
    [_,_,_,_,_,_,"#",_,"#",_,_,_,_,_,_],
    [_,_,_,_,_,_,_,"#",_,_,_,_,_,_,_]
    ]  
).