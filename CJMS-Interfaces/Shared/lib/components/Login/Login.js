// 
// Generic Shared login
// 
import React from "react";
import Select from 'react-select';
import * as Requests from "../Requests/Request";
export class Login extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            username: undefined,
            password: undefined,
            userOptions: [
                { value: 'admin', label: 'Admin' },
                { value: 'scorekeeper', label: 'Score Keeper' },
                { value: 'referee', label: 'Referee' },
                { value: 'head_referee', label: 'Head Referee' }
            ]
        };
    }
    async loginUser(credentials, allowedUser) {
        if (credentials.user !== allowedUser && credentials.user !== 'admin') {
            alert("User [" + credentials.user + "] is not permitted on this page");
            return false;
        }
        else {
            return Requests.CJMS_REQUEST_LOGIN(credentials);
        }
    }
    handleSubmit = async (e) => {
        e.preventDefault();
        const token = await this.loginUser({
            username: this.state.username,
            password: this.state.password
        }, this.props.allowedUser);
        if (token) {
            this.props.setToken(token);
        }
    };
    onUserChange = (user) => {
        this.setState({ username: user });
        console.log("Selected User: " + this.state.username);
    };
    render() {
        return (React.createElement("div", { className: "Login" },
            React.createElement("form", { onSubmit: this.handleSubmit },
                React.createElement("label", null, "User"),
                React.createElement(Select, { onChange: (e) => this.onUserChange(e.value), options: this.state.userOptions }),
                React.createElement("label", null, "Password"),
                React.createElement("input", { type: "password", onChange: (e) => this.setState({ password: e.target.value }) }),
                React.createElement("div", null,
                    React.createElement("button", { className: "buttonGreen", type: "submit" }, "Submit")))));
    }
}
