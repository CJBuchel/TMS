import React, { Component } from "react";
import Sidebar from "react-sidebar";
import { AiOutlineBars } from 'react-icons/ai';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import "../../assets/stylesheets/SideNavigation.scss";
export default class SideNavigation extends Component {
    constructor(props) {
        super(props);
        this.state = {
            sidebarOpen: false,
            routes: null
        };
        // this.setState({navContent: navContent});
        this.onSetSidebar = this.onSetSidebar.bind(this);
    }
    onSetSidebar(open) {
        this.setState({ sidebarOpen: open });
    }
    getRoute(link) {
        return (React.createElement(Route, { key: link.name, path: link.path, element: link.linkTo }));
    }
    getRoutes() {
        var routes = [];
        for (let link in this.props.navContent.links) {
            const l = this.props.navContent.links[link];
            routes.push(this.getRoute(l));
        }
        return (React.createElement(Router, null,
            React.createElement(Routes, null, routes)));
    }
    getContent() {
        var refs = [];
        for (let link in this.props.navContent.links) {
            const l = this.props.navContent.links[link];
            refs.push(React.createElement("a", { key: l.name, href: l.path },
                l.icon ? l.icon : null,
                " ",
                l.name));
        }
        return (React.createElement("div", { className: "side-navbar-content" },
            React.createElement("div", { className: "side-navbar-links" }, refs),
            React.createElement("div", { className: "side-navbar-footer" },
                React.createElement("h5", null,
                    "v",
                    process.env.REACT_APP_CJMS_VERSION))));
    }
    render() {
        return (React.createElement(React.Fragment, null,
            this.getRoutes(),
            React.createElement(Sidebar, { sidebar: this.getContent(), open: this.state.sidebarOpen, onSetOpen: this.onSetSidebar, styles: { sidebar: { background: this.props.navContent.background ? this.props.navContent.background : "#565657" } } },
                React.createElement("div", { className: "side-navbar" },
                    React.createElement("button", { onClick: () => this.onSetSidebar(true) },
                        React.createElement(AiOutlineBars, null))))));
    }
}
