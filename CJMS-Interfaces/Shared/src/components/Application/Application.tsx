// 
// Main application wrapper used by all interfaces
// 
import React, { Component } from "react";
import ReactDOM from "react-dom";
import { ConnectionCheck } from "./Connection";

// Import scss
import "../../assets/stylesheets/application.scss";
import "../../assets/stylesheets/Buttons.scss";
import "../../assets/stylesheets/ColourScheme.scss";

function Application(App:any) {
  return (
    <ConnectionCheck app={<App/>}/>
  );
}

// 
// THIS IS A REACT 17 APPLICATION (17.0.2)
// 
export function CJMS_Application(App:any) {
  // Global app requirements
  ReactDOM.render(
    Application(App),
    document.getElementById('root')
  );
}