import React from 'react';
import ReactDOM from 'react-dom';
import reportWebVitals from './reportWebVitals';
import {Login, useToken} from '@cj/shared';

import Scorer from './components/scorer';
// import './main.css';


function App() {
	const { token, setToken } = useToken();

	if (!token) {
		console.log("Token not made, redirecting")
		return <Login setToken={setToken} allowedUser={'referee'}/>
	}

	return (
		<div id='main-container' className={`ui centered grid ${0 ? 'fullscreen' : ''}`}>
			<Scorer/>
		</div>
	);
}

export default App;

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);