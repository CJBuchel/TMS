import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import {Login, CJMS_Application, useToken, comm_service, NavMenu, NavMenuContent } from '@cjms_interfaces/shared';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
// import { Setup } from './components/Setup';

import "./assets/application.scss";
import { Setup } from './components/Setup';
import { Users } from './components/Users';


/** Admin Structure,
 * Main Page (Setup/Main Control)
 * Events Control & Console (Comm server)
 * Team Stats/Scoring Editor
 * Scheduling?
 */
var navContent:NavMenuContent = {
  navCategories: [
    {
      name:"Setup",
      links: [
        {
          name:"Event Setup", 
          path:"/Setup", 
          linkTo:<Setup/>
        },

        {
          name:"Users Setup",
          path:"/Users",
          linkTo:<Users/>
        },
      ]
    }
  ]
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
        <NavMenu navContent={navContent}/>
      </div>
    );
  }
}

CJMS_Application(App);