// 
// Generic Shared login
// 
import React, { useState } from "react";
import Select from 'react-select';
import PropTypes from 'prop-types';
import * as Requests from "../Requests/Request";
import "../../assets/stylesheets/Login.scss";
function loginUser(credentials, allowedUsers) {
    var permitted = false;
    for (const allowedUser of allowedUsers) {
        console.log(allowedUser);
        if (credentials.username === allowedUser || credentials.username === 'admin') {
            permitted = true;
        }
    }
    if (!permitted) {
        alert("User [" + credentials.username + "] is not permitted on this page");
        return false;
    }
    else {
        return Requests.CJMS_REQUEST_LOGIN(credentials);
    }
}
const userOptions = [
    { value: 'admin', label: 'Admin' },
    { value: 'scorekeeper', label: 'Score Keeper' },
    { value: 'referee', label: 'Referee' },
    { value: 'head_referee', label: 'Head Referee' }
];
function Login({ setToken, allowedUsers }) {
    const [username, setUser] = useState('');
    const [password, setPassword] = useState('');
    const handleSubmit = async (e) => {
        e.preventDefault();
        const token = await loginUser({
            username: username,
            password: password
        }, allowedUsers);
        console.log(token);
        // console.log(token);
        if (token !== false && token.token) {
            console.log("Good Token");
            setToken(token);
        }
        else {
            console.log("Bad Token");
        }
    };
    const onUserChange = (user) => {
        setUser(user);
        console.log("Selected User: " + user);
    };
    return (React.createElement("div", { className: "Login" },
        React.createElement("form", { onSubmit: handleSubmit },
            React.createElement("label", null, "User"),
            React.createElement(Select, { onChange: e => onUserChange(e.value), options: userOptions }),
            React.createElement("label", null, "Password"),
            React.createElement("input", { type: "password", onChange: e => setPassword(e.target.value) }),
            React.createElement("div", null,
                React.createElement("button", { className: "buttonGreen", type: "submit" }, "Submit")))));
}
Login.propTypes = {
    setToken: PropTypes.func.isRequired
};
export default Login;
