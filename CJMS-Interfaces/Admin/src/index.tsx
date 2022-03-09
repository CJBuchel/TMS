import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { CJMS_Application } from '@cjms_interfaces/shared';

function App() {
  console.log(window.location.host);
  return (
    <div>
      <h1>This is a generic page</h1>
    </div>
  );
}

CJMS_Application(App);