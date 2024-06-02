import React,{useState} from "react";
import Game from './Game';

function PrincipalPage(){
    const [onPrincipalPage, setOnPrincipalPage] = useState(true);

    function toGame(){
        setOnPrincipalPage(false);
    }
    return (
        <>
        {onPrincipalPage  ? <div className="first-page">
            <h1>NONOGRAM</h1>
            <button onClick={toGame}> Comenzar</button>
        </div>
         : <Game/>}
        </>
    );
}
export default PrincipalPage;