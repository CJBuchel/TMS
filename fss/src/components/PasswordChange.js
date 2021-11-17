import React from "react";
import useState from "react";
import useEffect from "react";
import Axios from 'axios';

import "./Default.css";

const userUpdateRequest = "http://localhost:3001/api/updateUser";


function userPost(user, pass) {
	Axios.post(userUpdateRequest, {
		user: user,
		password: pass,
	}).then(() => {
		alert("User updated");
	});
}

class PasswordChange extends React.Component {
	constructor(props) {
		super(props)
		
		this.state = {
			admin: '',
			scorekeeper: '',
			referee: ''
		};
	}
	
	submitUser = () => {

		if (this.state.admin !== '') { userPost("admin", this.state.admin); }
		if (this.state.scorekeeper !== '') { userPost("scorekeeper", this.state.scorekeeper); }
		if (this.state.referee !== '') { userPost("referee", this.state.referee); }
	}

	render() {
		return (
			<div className="passwordChange">
				<h1>FSS Application, change below passwords</h1>
	
				<div className="passwords">
	
					<label>Admin password</label>
					<input type="text" name="admin_password" onChange={(e)=> {
						this.setState({admin: e.target.value})
					}}/>
					<p>{this.state.admin}</p>
					<br></br>
					<br></br>
	
	
					<label>Scorekeeper password</label>
					<input type="text" name="sk_password" onChange={(e)=> {
						this.setState({scorekeeper: e.target.value})
					}}/>
					<p>{this.state.scorekeeper}</p>
					<br></br>
					<br></br>
	
					<label>Referee password</label>
					<input type="text" name="ref_password" onChange={(e)=> {
						this.setState({referee: e.target.value})
					}}/>
					<p>{this.state.referee}</p>
					<br></br>
					<br></br>
					<button onClick={this.submitUser}>Submit</button>
	
				</div>
			</div>
		);
	}

}

export default PasswordChange;