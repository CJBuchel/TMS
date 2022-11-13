// 
// Connection to the server (monitor modal)
// 
import { comm_service } from "@cjms_shared/services";
import React, { Component } from "react";
import "../../assets/stylesheets/ConnectionModal.scss";
export class ConnectionCheck extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isOnline: false,
            retryCount: 0
        };
        comm_service.listeners.onSystemRefresh(() => {
            window.location.reload();
        });
        this.connectionCheck = this.connectionCheck.bind(this);
    }
    async componentDidMount() {
        this.startLoop();
    }
    componentWillUnmount() {
        clearInterval(this.state.loop);
    }
    connectionCheck() {
        fetch("http://" + window.location.host).then(res => {
            this.setState({ isOnline: true });
            this.setState({ retryCount: 0 });
        }).catch((error) => {
            this.setState({ isOnline: false });
            var count = this.state.retryCount;
            this.setState({ retryCount: count++ });
        });
    }
    startLoop() {
        this.connectionCheck();
        this.setState({ loop: setInterval(this.connectionCheck, 2000) });
    }
    render() {
        if (this.state.isOnline) {
            return (this.props.app);
        }
        else {
            var retryString = this.state.retryCount.toString();
            if (this.state.retryCount === 69) {
                retryString = retryString + " Nice";
            }
            return (React.createElement("div", { className: "ConnectionWrapper" },
                React.createElement("div", { className: "ConnectionModalApp" }, this.props.app),
                React.createElement("div", { className: "ConnectionModalBackdrop" }),
                React.createElement("div", { className: "ConnectionModal animated fadeIn" },
                    React.createElement("h1", null, "NO CONNECTION"),
                    React.createElement("h4", null, "Server Fault: Cannot Ping CJMS"),
                    React.createElement("h5", null,
                        "Retry Count: ",
                        retryString))));
        }
    }
}
