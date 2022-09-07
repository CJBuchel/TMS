import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { Login, useToken, CJMS_Application } from '@cjms_interfaces/shared';
// import { Setup } from './components/Setup';

import "./assets/application.scss";
import { Setup } from './components/Setup';
import useScorer from './components/Setup/useScorer';
import useTable from './components/Setup/useTable';



function App() {
  const { token, setToken } = useToken();

  const { scorer, setScorer } = useScorer();
  const { table, setTable } = useTable();

  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['scorekeeper', 'referee', 'head_referee']}/>
  } else {
    console.log("Token made");
    console.log(scorer);
    console.log(table);
    if (!table) {
      return (
        <div className='scoring-app'>
          <Setup setScorer={setScorer} setTable={setTable}/>
        </div>
      );
    } else {
      return (0);
    }
  }
}

CJMS_Application(App);