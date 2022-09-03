import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { CJMS_Application } from '@cjms_interfaces/shared';
// import { Setup } from './components/Setup';

import "./assets/application.scss";
import { Display } from './components/Display';

function App() {
  return (
    <div>
      <Display/>
    </div>
  );
}

CJMS_Application(App);