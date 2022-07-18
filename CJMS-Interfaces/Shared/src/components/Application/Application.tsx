// 
// Main application wrapper used by all interfaces
// 
import React from "react";
import ReactDOM from "react-dom";
import useToken from "../Login/UseToken";
import { ConnectionCheck } from "./Connection";

// Import scss
import "../../assets/stylesheets/application.scss";
import "../../assets/stylesheets/Buttons.scss";
import "../../assets/stylesheets/ColourScheme.scss";

function Application(App:any) {
  return (
    <ConnectionCheck>
      <App/>
    </ConnectionCheck>
  );
}
// Global app funciton
export function CJMS_Application(App:any) {
  // Global app requirements
  ReactDOM.render(
    Application(App),
    document.getElementById('root')
  );
}