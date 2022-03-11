import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { CJMS_Application, useToken, Login } from '@cjms_interfaces/shared';

function App() {
  // Login system
  const { token, setToken } = useToken();

  if (!token) {
    return (<Login setToken={setToken} allowedUser={'admin'}/>);
  } else {
    return (
      <div>
        <h1>This is a generic page</h1>
      </div>
    );
  }
}

CJMS_Application(App);