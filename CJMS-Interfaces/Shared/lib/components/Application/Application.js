// 
// Main application wrapper used by all interfaces
// 
import React from "react";
import ReactDOM from "react-dom";
import { ConnectionCheck } from "./Connection";
function Application(App) {
    return (React.createElement(ConnectionCheck, null,
        React.createElement(App, null)));
}
// Global app funciton
export function CJMS_Application(App) {
    // Global app requirements
    ReactDOM.render(Application(App), document.getElementById('root'));
}
