import React, { Component } from "react";
import Sidebar from "react-sidebar";
import { AiOutlineBars } from 'react-icons/ai';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { JsxElement } from "typescript/lib/tsserverlibrary";

import "../../assets/stylesheets/SideNavigation.scss";

export interface NavContentLink {
  icon:any;
  name:string;
  path:string;
  linkTo:any;
}

export interface NavContent {
  background:string;
  title:string;
  links:Array<NavContentLink>;
}

interface IProps {
  navContent:NavContent
}

interface IState {
  sidebarOpen:boolean;
  routes:any[];
}

export default class SideNavigation extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      sidebarOpen:false,
      routes:null
    }

    // this.setState({navContent: navContent});
    this.onSetSidebar = this.onSetSidebar.bind(this);
  }

  onSetSidebar(open:boolean) {
    this.setState({sidebarOpen: open})
  }

  getRoute(link:NavContentLink) {
    return (
      <Route key={link.name} path={link.path} element={link.linkTo}/>
    )
  }

  getRoutes() {
    var routes:any[] = [];
    for (let link in this.props.navContent.links) {
      const l:NavContentLink = this.props.navContent.links[link];
      routes.push(this.getRoute(l));
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
    var refs:Array<any> = [];
    
    for (let link in this.props.navContent.links) {
      const l:NavContentLink = this.props.navContent.links[link];
      refs.push(<a key={l.name} href={l.path}>{l.icon ? l.icon : null} {l.name}</a>);
    }

    return (
      <div className="side-navbar-content">
        <div className="side-navbar-links">
          { refs }
        </div>
        <div className="side-navbar-footer">
          <h5>v{process.env.REACT_APP_CJMS_VERSION}</h5>
        </div>
      </div>
    );
  }

  render() {
    return (
      <>
        {this.getRoutes()}
          <Sidebar
            sidebar={ this.getContent() }
            open={this.state.sidebarOpen}
            onSetOpen={this.onSetSidebar}
            styles={{sidebar: {background: this.props.navContent.background ? this.props.navContent.background : "#565657"}}}
          >

            <div className="side-navbar">
              <button onClick={() => this.onSetSidebar(true)} ><AiOutlineBars/></button>
            </div>
          </Sidebar>
      </>
    );
  }
}