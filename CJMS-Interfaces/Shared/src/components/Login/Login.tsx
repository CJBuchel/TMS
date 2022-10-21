// 
// Generic Shared login
// 
import React, { useCallback, useState } from "react";
import Select, { defaultTheme } from 'react-select';
import PropTypes from 'prop-types';
import * as Requests from "../Requests/Request";

import "../../assets/stylesheets/Login.scss"

function loginUser(credentials, allowedUsers) {
  var permitted = false;
  for (const allowedUser of allowedUsers) {
    console.log(allowedUser)
    if (credentials.username === allowedUser || credentials.username === 'admin') {
      permitted = true;
    }
  }

  if (!permitted) {
    alert("User [" + credentials.username + "] is not permitted on this page");
    return false;
  } else {
    return Requests.CJMS_REQUEST_LOGIN(credentials);
  }
}

const userOptions = [
  {value: 'admin', label: 'Admin'},
  {value: 'scorekeeper', label: 'Score Keeper'},
  {value: 'referee', label: 'Referee'},
  {value: 'head_referee', label: 'Head Referee'}
];

function Login({setToken, allowedUsers}) {
  const [username, setUser] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async e => {
    e.preventDefault();
    const token:any = await loginUser({
      username: username,
      password: password
    }, allowedUsers);

    console.log(token);

    // console.log(token);
    if (token !== false && token.token) {
      console.log("Good Token");
      setToken(token);
    } else {
      console.log("Bad Token");
    }
  }

  const onUserChange = (user) => {
    setUser(user);
    console.log("Selected User: " + user);
  }

  return (
    <div className="Login">
      <form onSubmit={handleSubmit}>
        <label>User</label>
        <Select onChange={e => onUserChange(e.value)} options={userOptions}/>
        <label>Password</label>
        <input type="password" onChange={e => setPassword(e.target.value)}/>
        <div>
          <button className="buttonGreen" type="submit">Submit</button>
        </div>
      </form>
    </div>
  );
}

Login.propTypes = {
  setToken: PropTypes.func.isRequired
}

export default Login;