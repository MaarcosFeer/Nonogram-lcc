import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ToggleButton from './ToggleButton';
import WinnerModal from './WinnerModal';
let pengine;


function Game({gameOn}) {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [satisfiedRowClues, setSatisfiedRowClues] = useState(null);
  const [satisfiedColClues, setSatisfiedColClues] = useState(null);
  const[isWin,setIsWin]=useState(false);
  const [animationSucessfully, setAnimationSucessfully] = useState(false);
  
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
      if (success ) {
        let gridS = response['Grid'];
        let rowCluesS = response['RowClues'];
        let colCluesS = response['ColumClues'];
        setGrid(gridS);
        setRowsClues(rowCluesS);
        setColsClues(colCluesS);
        setSatisfiedRowClues(Array(rowCluesS.length).fill(0));
        setSatisfiedColClues(Array(colCluesS.length).fill(0));
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
          if(response['IsAWin']){
              setIsWin(true);
              setTimeout(()=>{
                setWaiting(false);
                setIsWin(false);
                setAnimationSucessfully(true);
              },3000);
          }
      })
    }
  }, [satisfiedColClues, satisfiedRowClues]);
  function resetGame(){
    setAnimationSucessfully(false);
    PengineClient.init(handleServerReady);
  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting || isWin) {
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

  function onClickToggleButton() {
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
      {isWin && <div className='container'>

                  <div className='box'>
                    <span style={{'--i':1}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':2}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':3}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':4}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':5}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':6}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':7}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':8}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':9}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':10}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':11}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':12}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':13}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':14}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':15}}><i>WON</i> WON <i>WON</i> </span>
                    <span style={{'--i':16}}><i>WON</i> WON <i>WON</i> </span>
                  </div>
                </div>
      }
      {animationSucessfully &&  <WinnerModal resetGame={resetGame}/>}
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        satisfiedRowClues={satisfiedRowClues}
        satisfiedColClues={satisfiedColClues}
       />
       <ToggleButton onClickToggleButton={() => onClickToggleButton()}/>
      
      </div>
  );
}
export default Game;