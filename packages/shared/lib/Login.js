import React from 'react';
const Login = ({ whom = 'World' }) => {
    return (React.createElement("h1", null,
        "Hello ",
        whom));
};
export default Login;
