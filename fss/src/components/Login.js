import Select from 'react-select';
import React, { useState } from "react";
import PropTypes from 'prop-types';

import "./Default.css";
import "./Buttons.css";
import { Axios } from 'axios';
import { message } from 'statuses';

const loginRequest = "http://localhost:3001/api/login";

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

		// console.log("Token is: " + token);
		// if (token !== '') {
			// console.log(token);
			// setToken(token);
		// }
	}

	const onUserChange = (user) => {
		setUser(user);
		console.log("Selected User: " + user);
	}


	return (
		<div className="Login">
		<form onSubmit={handleSubmit}>
			<label>User</label>
			<Select
				value={options.value}
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