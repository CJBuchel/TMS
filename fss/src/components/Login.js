import Select from 'react-select';
import React, { useState } from "react";

function Login() {
	const userOptions = [
		{value: 'admin', label: 'admin'},
		{value: 'scorekeeper', label: 'scorekeeper'},
		{value: 'referee', label: 'referee'},
	]
	
	const [password, setPassword] = useState("");

	function validateForm() {
		return password.length > 0;
	}

	return (
		<div className="Login">
			<h1>Test</h1>
		</div>
	);
}

export default Login;