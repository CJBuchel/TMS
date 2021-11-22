import React, { Component } from "react";
import Axios from 'axios';

import './admin.css'

const request = "http://" + window.location.hostname + ":3001/api";
const userUpdateRequest = request + "/updateUser";

interface IProps {

}

interface IState {
	admin: string;
	scorekeeper: string;
	referee: string;
}

async function userPost(user:any, pass:any) {
	await fetch(userUpdateRequest, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},

		body: JSON.stringify({user, pass})
	}).then(response => {
		return response.json();
	}).then(data => {
		console.log(data)
		alert(data.message);
	});
}

class PasswordChange extends Component<IProps, IState> {
	constructor(props:any) {
		super(props);

		this.state = {
			admin: '',
			scorekeeper: '',
			referee: '',
		}
	}

	submitUser = () => {
		if (this.state.admin !== '') { userPost("admin", this.state.admin); }
		if (this.state.scorekeeper !== '') { userPost("scorekeeper", this.state.scorekeeper); }
		if (this.state.referee !== '') { userPost("referee", this.state.referee); }
	}

	render() {
		return(
			<div className="passwordChange">	
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
					<button className='hoverButton orange' onClick={this.submitUser}>Submit</button>
	
				</div>
			</div>
		);
	}
}

export default PasswordChange;