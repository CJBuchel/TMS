import React from "react";
import useState from "react";
import useEffect from "react";
import Axios from 'axios';

import './admin.css'

const userUpdateRequest = "http://localhost:3001/api/updateUser";


function userPost(user='', pass='') {
	Axios.post(userUpdateRequest, {
		user: user,
		password: pass,
	}).then(() => {
		alert("User updated");
	});
}

function MainApp() {
	return(
		<div>Test</div>
	);
}

export default MainApp;