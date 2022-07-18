import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import {Login, CJMS_Application, useToken, comm_service, SideNavigation, NavContent } from '@cjms_interfaces/shared';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Setup } from './components/Setup';

import "./assets/application.scss";


/** Admin Structure,
 * Main Page (Setup/Main Control)
 * Events Control & Console (Comm server)
 * Team Stats/Scoring Editor
 * Scheduling?
 */

var navContent:NavContent = {
  background:"#111",
  title:"Admin Nav",
  links:[
    { icon:null, name:"Setup", path:"/", linkTo:<Setup/> }
  ],
}

function App() {
  const { token, setToken } = useToken();
  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['admin']}/>;
  } else {
    console.log("Token made");
    return (
      <div className='admin-app'>
        <SideNavigation navContent={navContent}/>
      </div>
    );
  }
}

CJMS_Application(App);