import React from "react";
import "./index.css";

 function ToggleButton ({onClickToggleButton}) {
    return( 
        <div className="toggleButton">
            <label className="toggleButton">
                <input type="checkbox" onClick={onClickToggleButton}/>
                <span className="slider"/>
            </label>
        </div>
    )
}
export default ToggleButton;