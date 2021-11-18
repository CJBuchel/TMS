import React, {useState} from 'react';
import ReactDOM from 'react-dom';

import PasswordChange from './components/PasswordChange';
import Login from './components/Login';

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import useToken from './components/useToken';

function App() {
	const { token, setToken } = useToken();

	if (!token) {
		console.log("Token not made, redirecting")
		return <Login setToken={setToken}/>
	}

	return (
		<Router>
			<Routes>
				<Route exact path="/" element={<PasswordChange/>}/>
			</Routes>
		</Router>
	);
}

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);
