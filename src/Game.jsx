import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ToggleButton from './ToggleButton';
import WinnerModal from './WinnerModal';
import Lottie from 'lottie-react';
import loadingAnimation from './animations/loadingAnimation.json';
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
  const [lostGame,setLostGame] = useState(false);
  const [lives,setLives] = useState(null);

  /*Elevo el estado que controla el toggleButton para saber cuando colocar cruces y cuando pintar */
  const [onCrossMode, setOnCrossMode] = useState(true);
   //Estado de la lamparita para saber cuando está activa
   const [onRevealMode,setOnRevealMode] = useState(false);
   //Estado del botón de resetear el juego
   //Estado del botón que muestra el tablero resuelto
   const [showingSolvedGrid, setShowingSolvedGrid] = useState(false);
   //Almacena el tablero oculto
   const [hiddenGrid, setHiddenGrid] = useState(null);
  
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
        setLives(Array(3).fill(1));
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

        const querySG = `solveGame(${rowCluesS},${colCluesS},${gridS},SolvedGrid)`;
        pengine.query(querySG, (success, response) => {
          if (success) {
            setHiddenGrid(response['SolvedGrid']);
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
    setLostGame(false);
    PengineClient.init(handleServerReady);
  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting || showingSolvedGrid||isWin) {
      return;
    }

    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    let content;
    if(onRevealMode){
      content = hiddenGrid[i][j];
    }else{
      content= onCrossMode ? 'X' : '#';
    }
    if(content !== hiddenGrid[i][j]){
      updateLives();
    }
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
  function updateLives(){
    const index = lives.lastIndexOf(1);
    if(index !== -1){
      const newLives = [...lives];
      newLives[index] = 0;
      setLives(newLives);
    }
    //Si el jugador pierde la última vida, pierde el juego y debo reiniciarlo
    if(lives[1] === 0)
      setLostGame(true);
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
    if (waiting || hiddenGrid === null) {
      return;
    }
    setOnCrossMode(!onCrossMode);
  }

  if (!grid) {
    return null;
  }
  function onclickClueGridButton(){
    if (waiting || hiddenGrid === null) {
      return;
    }
    setShowingSolvedGrid(!showingSolvedGrid);
    setGrid(hiddenGrid);
    setHiddenGrid(grid);
  }
  function onclickClueSquareButton(){
    if (waiting || hiddenGrid ===null) {
      return;
    }
    setOnRevealMode(!onRevealMode);
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
      <div>
        {lives.map((content, index) => (
          <img
            key={index}
            src={content === 1 ? "/images/heart.png" : "/images/emptyHeart.png"}
            alt={content === 1 ? "full heart" : "empty heart"}
            style={{ width: '50px', height: '50px' }} // Ajusta el tamaño de la imagen según sea necesario
          />
        ))}
      </div>
      {(animationSucessfully || lostGame) &&  <WinnerModal resetGame={resetGame}/>}
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
        satisfiedRowClues={satisfiedRowClues}
        satisfiedColClues={satisfiedColClues}
       />
      <div className='buttons'>
        <ToggleButton onClickToggleButton={() => onClickToggleButton()}/>
            <button  className={`clueGridButton ${showingSolvedGrid?"active":""}`} onClick={()=>onclickClueGridButton()}>
              <svg width="68px" height="30px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M8.4 3H4.6C4.03995 3 3.75992 3 3.54601 3.10899C3.35785 3.20487 3.20487 3.35785 3.10899 3.54601C3 3.75992 3 4.03995 3 4.6V8.4C3 8.96005 3 9.24008 3.10899 9.45399C3.20487 9.64215 3.35785 9.79513 3.54601 9.89101C3.75992 10 4.03995 10 4.6 10H8.4C8.96005 10 9.24008 10 9.45399 9.89101C9.64215 9.79513 9.79513 9.64215 9.89101 9.45399C10 9.24008 10 8.96005 10 8.4V4.6C10 4.03995 10 3.75992 9.89101 3.54601C9.79513 3.35785 9.64215 3.20487 9.45399 3.10899C9.24008 3 8.96005 3 8.4 3Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M19.4 3H15.6C15.0399 3 14.7599 3 14.546 3.10899C14.3578 3.20487 14.2049 3.35785 14.109 3.54601C14 3.75992 14 4.03995 14 4.6V8.4C14 8.96005 14 9.24008 14.109 9.45399C14.2049 9.64215 14.3578 9.79513 14.546 9.89101C14.7599 10 15.0399 10 15.6 10H19.4C19.9601 10 20.2401 10 20.454 9.89101C20.6422 9.79513 20.7951 9.64215 20.891 9.45399C21 9.24008 21 8.96005 21 8.4V4.6C21 4.03995 21 3.75992 20.891 3.54601C20.7951 3.35785 20.6422 3.20487 20.454 3.10899C20.2401 3 19.9601 3 19.4 3Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M19.4 14H15.6C15.0399 14 14.7599 14 14.546 14.109C14.3578 14.2049 14.2049 14.3578 14.109 14.546C14 14.7599 14 15.0399 14 15.6V19.4C14 19.9601 14 20.2401 14.109 20.454C14.2049 20.6422 14.3578 20.7951 14.546 20.891C14.7599 21 15.0399 21 15.6 21H19.4C19.9601 21 20.2401 21 20.454 20.891C20.6422 20.7951 20.7951 20.6422 20.891 20.454C21 20.2401 21 19.9601 21 19.4V15.6C21 15.0399 21 14.7599 20.891 14.546C20.7951 14.3578 20.6422 14.2049 20.454 14.109C20.2401 14 19.9601 14 19.4 14Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M8.4 14H4.6C4.03995 14 3.75992 14 3.54601 14.109C3.35785 14.2049 3.20487 14.3578 3.10899 14.546C3 14.7599 3 15.0399 3 15.6V19.4C3 19.9601 3 20.2401 3.10899 20.454C3.20487 20.6422 3.35785 20.7951 3.54601 20.891C3.75992 21 4.03995 21 4.6 21H8.4C8.96005 21 9.24008 21 9.45399 20.891C9.64215 20.7951 9.79513 20.6422 9.89101 20.454C10 20.2401 10 19.9601 10 19.4V15.6C10 15.0399 10 14.7599 9.89101 14.546C9.79513 14.3578 9.64215 14.2049 9.45399 14.109C9.24008 14 8.96005 14 8.4 14Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
            <button className={`clueSquareButton ${onRevealMode?"active":""}`} onClick={()=>onclickClueSquareButton()}>
              <svg width="68px" height="30px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 21L16.65 16.65M11 6C13.7614 6 16 8.23858 16 11M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
            <button className="resetButton" onClick={()=>resetGame()}>
            <svg width="68px" height="30px" viewBox="0 0 21 21" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" transform="translate(2 2)"><path d="m12.5 1.5c2.4138473 1.37729434 4 4.02194088 4 7 0 4.418278-3.581722 8-8 8s-8-3.581722-8-8 3.581722-8 8-8"/><path d="m12.5 5.5v-4h4"/></g></svg>
            </button>
      </div> 
      {hiddenGrid === null && (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}> {/* Centrar la animación y el texto */}
          <Lottie 
            animationData={loadingAnimation} // La animación se carga desde el JSON
            loop={true} // La animación se reproducirá en bucle
            autoplay={true} // La animación se reproducirá automáticamente
            style={{ width: 50, height: 50 }} // Estilo para ajustar el tamaño de la animación
          />
          <p>Generating Solution</p>
        </div>
      )}
      </div>
  );
}
export default Game;