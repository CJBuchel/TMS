// 
// Connection to the server (monitor modal)
// 
import { comm_service } from "@cjms_shared/services";
import React, { Component } from "react";
import "../../assets/stylesheets/ConnectionModal.scss";
export class ConnectionCheck extends Component {
    count = 0;
    constructor(props) {
        super(props);
        this.state = {
            isOnline: true,
            retryCount: 0
        };
        comm_service.listeners.onSystemRefresh(() => {
            window.location.reload();
        });
        this.connectionCheck = this.connectionCheck.bind(this);
    }
    componentDidMount() {
        this.startLoop();
    }
    componentWillUnmount() {
        clearInterval(this.state.loop);
    }
    connectionCheck() {
        fetch("http://" + window.location.host).then(res => {
            this.setState({ isOnline: true });
            this.count = 0;
            this.setState({ retryCount: 0 });
        }).catch((error) => {
            this.setState({ isOnline: false });
            this.count++;
            this.setState({ retryCount: this.count });
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
            return (React.createElement("div", { className: "ConnectionWrapper" },
                React.createElement("div", { className: "ConnectionModalApp" }, this.props.app),
                React.createElement("div", { className: "ConnectionModalBackdrop" }),
                React.createElement("div", { className: "ConnectionModal animated fadeIn" },
                    React.createElement("h1", null, "NO CONNECTION"),
                    React.createElement("h4", null, "Server Fault: Cannot Ping CJMS"),
                    React.createElement("h5", null,
                        "Retry Count: ",
                        this.state.retryCount === 69 ? `${this.state.retryCount} Nice` : this.state.retryCount))));
        }
    }
}
