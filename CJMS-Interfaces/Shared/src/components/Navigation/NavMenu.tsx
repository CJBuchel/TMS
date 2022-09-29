// 
// Generic shared navbar
// 
import { comm_service, request_namespaces } from "@cjms_shared/services";
import React, { Component } from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";

import "../../assets/stylesheets/NavMenu.scss";
import { CJMS_FETCH_GENERIC_GET } from "../Requests/Request";

export interface NavMenuLink {
  name:string;
  path:string;
  linkTo:any;
}

export interface NavMenuCategory {
  name:string;
  links:Array<NavMenuLink>
}

export interface NavMenuContent {
  navCategories:Array<NavMenuCategory>
}

interface IProps {
  navContent:NavMenuContent
}

interface IState {
  external_eventData:any;
  eventState:string;
}

export default class NavMenu extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: undefined,
      eventState: "Awaiting"
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      this.setEventData(eventData);
    });

    comm_service.listeners.onEventState(async (e:any) => {
      this.setEventState(e);
    });
  }
  
  setEventState(stateData:any) {
    this.setState({eventState: stateData});
  }

  setEventData(eventData:any) {
    this.setState({external_eventData: eventData.data});
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    this.setEventData(eventData);
  }

  getRoute(link:NavMenuLink) {
    return (
      <Route key={link.name} path={link.path} element={link.linkTo}/>
    );
  }

  clearSessionStorage() {
    sessionStorage.clear();
    window.location.reload();
  }

  getRoutes() {
    var routes:any[] = [];
    for (const cat of this.props.navContent.navCategories) {
      for (const link of cat.links) {
        routes.push(this.getRoute(link));
      }
    }

    return (
      <Router>
        <Routes>
          { routes }
        </Routes>
      </Router>
    );
  }

  getContent() {
    var categories:Array<any> = [];

    for (const cat of this.props.navContent.navCategories) {
      var links:any[] = [];
      for (const link of cat.links) {
        links.push(<a key={link.name} href={link.path}>{link.name}</a>)
      }

      categories.push(
        <div key={cat.name} className="column">
          <h3>{cat.name}</h3>
          {links}
        </div>
      );
    }


    return(
      <div className="row">
        {categories}
      </div>
    );
  }

  getState() {
    var color = 'White';
    if (this.state.eventState=='Awaiting') {
      color = "White";
    } else if (this.state.eventState=='Idle') {
      color = "White";
    } else if (this.state.eventState=='Match Loaded') {
      color = "Orange";
    } else if (this.state.eventState=='Pre-Running') {
      color = "Yellow";
    } else if (this.state.eventState=='Running') {
      color = "Green";
    } else if (this.state.eventState=='Aborted') {
      color = "Red";
    }

    return <b><span id="nav-state-name">{this.state.external_eventData?.event_name} | </span>State: <span style={{color: `${color}`}}>{this.state.eventState}</span></b>
  }

  getMode() {
    var mode;
    if (this.state.external_eventData?.match_locked) {
      mode = <span style={{color: "red"}}>Match Locked</span>
    } else {
      mode = <span style={{color: "dodgerblue"}}>Match Free</span>
    }

    return <b>Mode: {mode}</b>
  }


  render() {
    return (
      <>
        <div className="navbar">

          {/* Home */}
          <a href="/">Home</a>

          {/* Menu */}
          <div className="dropdown">
            <button className="dropbtn">Menu<i className="fa fa-caret-down"></i></button>
            <div className="dropdown-content">
              <div className="header">
                <h4>CJMS - {process.env.REACT_APP_CJMS_VERSION}</h4>
              </div>
              {this.getContent()}
            </div>
          </div>


          {/* Navbar right */}
          <div className="navbar-right">
            <span id="nav-state">
              {this.getState()}
            </span>
            <span id="nav-mode">
              {this.getMode()}
            </span>
            <span id="nav-logout">
              <a onClick={this.clearSessionStorage}>Logout</a>
            </span>
          </div>
        </div>
        {this.getRoutes()}
      </>
    )
  }
}