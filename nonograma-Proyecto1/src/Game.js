import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [satisfiedRowClues, setSatisfiedRowClues] = useState(null);
  const [satisfiedColClues, setSatisfiedColClues] = useState(null);
  /*Elevo el estado que controla el toggleButton para saber cuando colocar cruces y cuando pintar */
  const [onCrossMode, setOnCrossMode] = useState(true);

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        let gridS = response['Grid'];
        let rowCluesS = response['RowClues'];
        let colCluesS = response['ColumClues'];
        setGrid(gridS);
        setRowsClues(rowCluesS);
        setColsClues(colCluesS);
        //Modifico las variables para poder usarlas en la siguiente query
        gridS = JSON.stringify(response['Grid']);
        rowCluesS = JSON.stringify(response['RowClues']);
        colCluesS = JSON.stringify(response['ColumClues']);
        //Inicializo las listas que chequean si las pistas están satisfechas
        const queryI = `initClues(${gridS},${rowCluesS},${colCluesS},NewSatisfiedRowClues,NewSatisfiedColClues)`;
        pengine.query(queryI, (success, response) => {
          if (success) {
            setSatisfiedRowClues(response['NewSatisfiedRowClues']);
            setSatisfiedColClues(response['NewSatisfiedColClues']);
            //Borrar
            console.log(response['NewSatisfiedRowClues']);
            console.log(response['NewSatisfiedColClues']);
          }
        })

      }
    });
  }
  //Chequeo el estado del juego (si se completó el nivel o hay que seguir jugando) cada vez que hay una modificación en las pistas
  useEffect(() => {
    if (satisfiedColClues && satisfiedRowClues) {
      const satisfiedRowCluesS = JSON.stringify(satisfiedRowClues);
      const satisfiedColCluesS = JSON.stringify(satisfiedColClues);
      const queryWinS = `checkWin("${satisfiedRowCluesS}",${satisfiedColCluesS},IsAWin)`;
      pengine.query(queryWinS, (success, response) => {
        if (success)
          console.log(response['IsAWin']);
      })
    }
  }, [satisfiedColClues, satisfiedRowClues]);

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting) {
      return;
    }

    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const content = onCrossMode ? 'X' : '#';
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const queryS = `put("${content}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        updateSatisfiedClues(i, j, response['RowSat'], response['ColSat']);
      }
      setWaiting(false);
    });
  }

  function updateSatisfiedClues(i, j, rowSat, colSat) {
    const newSatisfiedRowClues = [...satisfiedRowClues];
    const newSatisfiedColClues = [...satisfiedColClues];
    newSatisfiedRowClues[i] = rowSat;
    newSatisfiedColClues[j] = colSat;
    setSatisfiedRowClues(newSatisfiedRowClues);
    setSatisfiedColClues(newSatisfiedColClues);
  }

  function handleClickToggleButton() {
    if (waiting) {
      return;
    }
    setOnCrossMode(!onCrossMode);
  }

  if (!grid) {
    return null;
  }

  return (
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        onClickToggleButton={() => handleClickToggleButton()}
        satisfiedRowClues={satisfiedRowClues}
        satisfiedColClues={satisfiedColClues}
      />
    </div>
  );
}

export default Game;