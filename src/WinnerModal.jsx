import React from "react";
export function WinnerModal ({ resetGame }) {
  return (
    <section className='winner'>
      <div className='text'>
        <footer>
          <button onClick={resetGame}>Empezar de nuevo</button>
        </footer>
     </div>
    </section>
  )
}
 export default WinnerModal;