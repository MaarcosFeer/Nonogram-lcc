import React from 'react';

function Square({ value, onClick }) {
    let cube;
    if(value === "#"){
           cube = "squareSelect"; 
    }
    return (
        <button className={`square ${cube}`} onClick={onClick}>
            {value !== '_' ? value : null}
        </button>
        
    );
}

export default Square;