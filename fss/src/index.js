import React from 'react';
import ReactDOM from 'react-dom';

import PasswordChange from './components/PasswordChange';

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

ReactDOM.render(
	<Router>
		<Routes>
			<Route exact path="/" element={<PasswordChange/>}/>
		</Routes>
	</Router>,

	document.getElementById('root')
);
