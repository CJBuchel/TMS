// 
// Generic shared navbar
// 
import { comm_service, request_namespaces } from "@cjms_shared/services";
import React, { Component } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import "../../assets/stylesheets/NavMenu.scss";
import { CJMS_FETCH_GENERIC_GET } from "../Requests/Request";
export default class NavMenu extends Component {
    constructor(props) {
        super(props);
        this.state = {
            external_eventData: undefined
        };
        comm_service.listeners.onEventUpdate(async () => {
            const eventData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
            this.setEventData(eventData);
        });
    }
    setEventData(eventData) {
        this.setState({ external_eventData: eventData.data });
    }
    async componentDidMount() {
        const eventData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
        this.setEventData(eventData);
    }
    getRoute(link) {
        return (React.createElement(Route, { key: link.name, path: link.path, element: link.linkTo }));
    }
    clearSessionStorage() {
        sessionStorage.clear();
        window.location.reload();
    }
    getRoutes() {
        var routes = [];
        for (const cat of this.props.navContent.navCategories) {
            for (const link of cat.links) {
                routes.push(this.getRoute(link));
            }
        }
        return (React.createElement(Router, null,
            React.createElement(Routes, null, routes)));
    }
    getContent() {
        var categories = [];
        for (const cat of this.props.navContent.navCategories) {
            var links = [];
            for (const link of cat.links) {
                links.push(React.createElement("a", { key: link.name, href: link.path }, link.name));
            }
            categories.push(React.createElement("div", { key: cat.name, className: "column" },
                React.createElement("h3", null, cat.name),
                links));
        }
        return (React.createElement("div", { className: "row" }, categories));
    }
    getMode() {
        var mode;
        if (this.state.external_eventData?.match_locked) {
            mode = React.createElement("span", { style: { color: "red" } }, "Match Locked");
        }
        else {
            mode = React.createElement("span", { style: { color: "dodgerblue" } }, "Match Free");
        }
        return React.createElement("b", null,
            this.state.external_eventData?.event_name,
            " | Mode: ",
            mode);
    }
    render() {
        return (React.createElement(React.Fragment, null,
            React.createElement("div", { className: "navbar" },
                React.createElement("a", { href: "/" }, "Home"),
                React.createElement("div", { className: "dropdown" },
                    React.createElement("button", { className: "dropbtn" },
                        "Menu",
                        React.createElement("i", { className: "fa fa-caret-down" })),
                    React.createElement("div", { className: "dropdown-content" },
                        React.createElement("div", { className: "header" },
                            React.createElement("h4", null,
                                "CJMS - ",
                                process.env.REACT_APP_CJMS_VERSION)),
                        this.getContent())),
                React.createElement("div", { className: "navbar-right" },
                    this.getMode(),
                    React.createElement("a", { onClick: this.clearSessionStorage }, "Logout"))),
            this.getRoutes()));
    }
}
