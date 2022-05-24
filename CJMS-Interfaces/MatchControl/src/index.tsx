import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import {Login, CJMS_Application, useToken, comm_service } from '@cjms_interfaces/shared';

import "./assets/stylesheets/application.scss"

function NavBar() {
  return (
    <div className='navbar'>
      test
    </div>
  );
}

function IndexRouter() {
  return (
    <Router>
      <Routes>
        {/* Match Control Page Redirect (Landing) */}
        <Route path="/" element={<Navigate to="/MatchControl"/>}/>

        {/* Match Control Page */}
        <Route path="/MatchControl" element={null}/>

        {/* Match Statistics Controller Page */}
        <Route path="/MatchStats" element={null}/>
      </Routes>
    </Router>
  );
}

function App() {
  const { token, setToken } = useToken();
  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['admin', 'head_referee']}/>;
  } else {
    console.log("Token made");
    return (
      <div>
        <NavBar/>
        <IndexRouter/>
      </div>
    );
  }
}

CJMS_Application(App);