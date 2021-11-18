import Select from 'react-select';
import React, { useState } from "react";
import PropTypes from 'prop-types';
import "./Buttons.css";
import "./Login.css";
const loginRequest = "http://localhost:3001/api/login";
const options = [
    { value: 'admin', label: 'admin' },
    { value: 'scorekeeper', label: 'scorekeeper' },
    { value: 'referee', label: 'referee' },
];
async function loginUser(credentials) {
    const response = await fetch(loginRequest, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(credentials)
    });
    return response.json();
}
function Login({ setToken }) {
    const [user, setUser] = useState('');
    const [password, setPassword] = useState('');
    const handleSubmit = async (e) => {
        e.preventDefault();
        const token = await loginUser({
            user,
            password
        });
        if (token.message) {
            alert("From Server: " + token.message);
        }
        setToken(token);
    };
    const onUserChange = (user) => {
        setUser(user);
        console.log("Selected User: " + user);
    };
    return (React.createElement("div", { className: "Login" },
        React.createElement("form", { onSubmit: handleSubmit },
            React.createElement("label", null, "User"),
            React.createElement(Select, { onChange: e => onUserChange(e.value), options: options }),
            React.createElement("label", null, "Password"),
            React.createElement("br", null),
            React.createElement("input", { type: "password", onChange: e => setPassword(e.target.value) }),
            React.createElement("div", null,
                React.createElement("button", { className: "buttonGreen", type: "submit" }, "Submit")))));
}
Login.propTypes = {
    setToken: PropTypes.func.isRequired
};
export default Login;
