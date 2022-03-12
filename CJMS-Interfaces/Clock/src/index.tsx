import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { CJMS_Application, commService } from '@cjms_interfaces/shared';

function App() {
  
  return (
    <div>
      <h1>This is a generic page</h1>
    </div>
  );
}

CJMS_Application(App);