// 
// Generic shared navbar
// 
import { comm_service } from "@cjms_shared/services";
import React, { Component } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import "../../assets/stylesheets/NavMenu.scss";
import { CJMS_REQUEST_EVENT } from "../Requests/Request";
export default class NavMenu extends Component {
    constructor(props) {
        super(props);
        this.state = {
            external_eventData: undefined,
            eventState: "Awaiting"
        };
        comm_service.listeners.onEventUpdate(async () => {
            const eventData = await CJMS_REQUEST_EVENT(true);
            this.setEventData(eventData);
        });
        comm_service.listeners.onEventState(async (e) => {
            this.setEventState(e);
        });
    }
    setEventState(stateData) {
        this.setState({ eventState: stateData });
    }
    setEventData(eventData) {
        this.setState({ external_eventData: eventData });
    }
    componentDidMount() {
        CJMS_REQUEST_EVENT(true).then((data) => {
            this.setEventData(data);
        });
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
    getState() {
        var color = 'White';
        if (this.state.eventState == 'Awaiting') {
            color = "White";
        }
        else if (this.state.eventState == 'Idle') {
            color = "White";
        }
        else if (this.state.eventState == 'Match Loaded') {
            color = "Orange";
        }
        else if (this.state.eventState == 'Pre-Running') {
            color = "Yellow";
        }
        else if (this.state.eventState == 'Running') {
            color = "Green";
        }
        else if (this.state.eventState == 'Aborted') {
            color = "Red";
        }
        return React.createElement("b", null,
            React.createElement("span", { id: "nav-state-name" },
                this.state.external_eventData?.event_name,
                " | "),
            "State: ",
            React.createElement("span", { style: { color: `${color}` } }, this.state.eventState));
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
            "Mode: ",
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
                    React.createElement("span", { id: "nav-state" }, this.getState()),
                    React.createElement("span", { id: "nav-mode" }, this.getMode()),
                    React.createElement("span", { id: "nav-logout" },
                        React.createElement("a", { onClick: this.clearSessionStorage }, "Logout")))),
            this.getRoutes()));
    }
}
