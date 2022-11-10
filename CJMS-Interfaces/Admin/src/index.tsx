import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { Login, CJMS_Application, useToken, NavMenu, NavMenuContent } from '@cjms_interfaces/shared';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

import "./assets/application.scss";
import { EventSetup } from './components/Setup/EventSetup';
import { UsersSetup } from './components/Setup/UserSetup';
import { TeamManagement } from './components/TeamManagement/TeamManagement';
import { Scoring } from './components/TeamManagement/Scoring';


/** Admin Structure,
 * Main Page (Setup/Main Control)
 * Team Manager/Scoring Editor
 * Scheduling/MatchControl?
 */
var navContent:NavMenuContent = {
  navCategories: [
    {
      name: "Setup",
      links: [
        {
          name: "Event Setup", 
          path: "/", 
          linkTo:<EventSetup/>
        },

        {
          name: "Users Setup",
          path: "/Users",
          linkTo:<UsersSetup/>
        },
      ]
    },

    {
      name: "Team Management",
      links: [
        {
          name: "Team Management",
          path: "/TeamManagement",
          linkTo:<TeamManagement/>
        },

        {
          name: "Scoring",
          path: "/Scoring",
          linkTo:<Scoring/>
        }
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