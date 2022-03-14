import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import Timer from './components/Timer';
import { CJMS_Application } from '@cjms_interfaces/shared';

import "./assets/stylesheets/application.scss";

function App() {
  return (
    <Timer/>
  );
}

CJMS_Application(App);