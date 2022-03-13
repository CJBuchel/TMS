import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import Clock from "./components/Clock";
import { CJMS_Application } from '@cjms_interfaces/shared';

import "./assets/stylesheets/application.scss";

function App() {
  return (
    <Clock/>
  );
}

CJMS_Application(App);