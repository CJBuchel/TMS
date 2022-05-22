import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import Timer from './components/Timer';
import { CJMS_Application, Login, useToken, comm_service } from '@cjms_interfaces/shared';

import "./assets/stylesheets/application.scss";

function App() {
  const { token, setToken } = useToken();
  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['head_referee', 'referee']}/>;
  } else {
    console.log("Token made");
    return (
      <Timer/>
    );
  }
}

CJMS_Application(App);