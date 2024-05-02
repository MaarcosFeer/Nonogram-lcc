import React from 'react';

function Clue({ clue, clueStyle } ) {
    return (
        <div className={`clue ${clueStyle}`} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;