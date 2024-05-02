import React from 'react';

function Square({ value, onClick }) {
    let cube;
    if(value === "#"){
           cube = "squareSelect"; 
    }
    return (
        <button className={`square ${cube}`} onClick={onClick}>
            {value === 'X' ? value : ''}
        </button>
        
    );
}

export default Square;