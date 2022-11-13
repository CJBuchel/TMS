// 
// Main application wrapper used by all interfaces
// 
import React from "react";
import ReactDOM from "react-dom";
import { ConnectionCheck } from "./Connection";
// Import scss
import "../../assets/stylesheets/application.scss";
import "../../assets/stylesheets/Buttons.scss";
import "../../assets/stylesheets/ColourScheme.scss";
function Application(App) {
    return (React.createElement(ConnectionCheck, { app: React.createElement(App, null) }));
}
// 
// THIS IS A REACT 17 APPLICATION (17.0.2)
// 
export function CJMS_Application(App) {
    // Global app requirements
    ReactDOM.render(Application(App), document.getElementById('root'));
}
