// 
// Generic shared navbar
// 
import React, { Component } from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";

import "../../assets/stylesheets/NavMenu.scss";

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
}

export default class NavMenu extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
    }
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

          {/* Logout */}
          <div className="navbar-right">
            <a onClick={this.clearSessionStorage}>Logout</a>
          </div>
        </div>
        {this.getRoutes()}
      </>
    )
  }
}