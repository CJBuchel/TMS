// 
// Generic Shared login
// 
import React from "react";
import * as Requests from "../Requests/Request";
class Login extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            username: undefined,
            password: undefined
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
}
