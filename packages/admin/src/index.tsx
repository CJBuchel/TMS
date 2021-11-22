import React from 'react';
import ReactDOM from 'react-dom';
import MainApp from './components/MainApp';
import reportWebVitals from './reportWebVitals';
import {Login, useToken} from '@cj/shared';

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';


function App() {
	const { token, setToken } = useToken();

	if (!token) {
		console.log("Token not made, redirecting")
		return <Login setToken={setToken} allowedUser={'admin'}/>
	}

	return (
		<Router>
			<Routes>
				<Route path="/" element={<MainApp/>}/>
			</Routes>
		</Router>
	);
}

export default App;

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);