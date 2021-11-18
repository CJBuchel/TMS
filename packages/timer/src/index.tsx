import React from 'react';
import ReactDOM from 'react-dom';
import reportWebVitals from './reportWebVitals';
import {Login, useToken} from '@cj/shared';

import './main.css';


import Clock from './clock'
import Sound from './sound'


function App() {
	const { token, setToken } = useToken();

	if (!token) {
		console.log("Token not made, redirecting")
		return <Login setToken={setToken}/>
	}

	return (
		<div id='main-container' className={`ui centered grid ${0 ? 'fullscreen' : ''}`}>
			<Clock/>
		</div>
	);
}

export default App;

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);