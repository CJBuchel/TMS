// 
// Main application wrapper used by all interfaces
// 
import React from "react";
import ReactDOM from "react-dom";
import { ConnectionCheck } from "./Connection";

function Application(App:any) {
  return (
    <ConnectionCheck><App/></ConnectionCheck>
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