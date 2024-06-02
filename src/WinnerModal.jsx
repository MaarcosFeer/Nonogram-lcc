import React, { useState } from "react";
export function WinnerModal ({ resetGame }) {
  const [inWinner,setInWinner] = useState("in");
  function setWinnerInOut(){
    if(inWinner === "out"){
        resetGame();
    }
  }
  function onclick(){
    setInWinner("out");
  }
  return (
    <section className={`winner ${inWinner}`} onAnimationEnd={setWinnerInOut}>
      <div className='text'>
        <footer>
          <button onClick={onclick}>Empezar de nuevo</button>
        </footer>
     </div>
    </section>
  )
}
 export default WinnerModal;