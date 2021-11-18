
import Select from 'react-select';
import React, { useState } from "react";
import PropTypes from 'prop-types';

import "./Buttons.css";
import "./Login.css";
import { Axios } from 'axios';
import { message } from 'statuses';

const loginRequest = "http://" + window.location.hostname + ":3001/api/login";

const options = [
	{value: 'admin', label: 'admin'},
	{value: 'scorekeeper', label: 'scorekeeper'},
	{value: 'referee', label: 'referee'},
]

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

function Login({setToken}) {

	const [user, setUser] = useState('');
	const [password, setPassword] = useState('');

	const handleSubmit = async e => {
		e.preventDefault();
		const token = await loginUser({
			user,
			password
		});

		if (token.message) {
			alert("From Server: " + token.message);
		}

		setToken(token);
	}

	const onUserChange = (user) => {
		setUser(user);
		console.log("Selected User: " + user);
		console.log(window.location.hostname);
	}


	return (
		<div className="Login">
		<form onSubmit={handleSubmit}>
			<label>User</label>
			<Select
				onChange={e => onUserChange(e.value)}
				options={options}
			/>
			<label>Password</label><br/>
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