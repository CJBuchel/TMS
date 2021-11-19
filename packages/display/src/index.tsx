import React from 'react';
import ReactDOM from 'react-dom';
import Display from './components/Display';
import reportWebVitals from './reportWebVitals';
import {Login, useToken} from '@cj/shared';

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

const request = "http://" + window.location.hostname + ":3001/api";
const get_teams_request = request+"/teams/get";

async function getTeams() {
	return await fetch(get_teams_request)
	.then((response) => {
		// console.log(response);
		return response.json();
	}).catch((error) => {
		console.log(error);
	});
	

	// for (const team of teams) {
	// 	console.log("This is a team: " + team.team_name);
	// }
	// console.log(teams);
	// var json_teams = teams.json();
}

function App() {
	const { token, setToken } = useToken();

	// Don't need login for display
	// if (!token) {
	// 	console.log("Token not made, redirecting")
	// 	return <Login setToken={setToken}/>
	// }

	return (
		<Router>
			<Routes>
				<Route path="/" element={<Display/>}/>
			</Routes>
		</Router>
	);
}

export default App;

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);