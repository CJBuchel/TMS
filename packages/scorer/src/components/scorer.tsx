import Select from 'react-select';
import React, { Component, useState } from "react";
import PropTypes from 'prop-types';

// import "./Buttons.css";
// import "./Login.css";

import "./scorer.css"

import { Axios } from 'axios';
import { IndexRouteProps } from 'react-router';

const request = "http://" + window.location.hostname + ":3001/api";
const get_teams_request = request+"/teams/get";
const post_score_request = request+"/teams/score";


const options = [
	{value: 'rank1', label: 'Rank 1'},
	{value: 'rank2', label: 'Rank 2'},
	{value: 'rank3', label: 'Rank 3'},
]

async function postScore(credentials:any) {

	const response = await fetch(post_score_request, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(credentials)
	});

	return response.json();
}


async function getTeamOptions() {
	var teamOptions = await fetch(get_teams_request)
	.then((response) => {
		// console.log(response);
		return response.json();
	}).then(data => {
	// for (const team of data) {
		// 	console.log(team.team_name);
		// }
		
		let teamOptions = data.map(function (team:any) {
			// console.log(team);
			// return {value: team.team_name, label: team.team_name};
			return teamOptions;
		});

		// console.log(returner);
		return teamOptions;
		
	}).catch((error) => {
		console.log(error);
	});

	return teamOptions;

	// return (
	// 	<Select
	// 		// onChange={(e:any) => onScoreChange(e.value)}
	// 		// options={teamOptions}
	// 	/>
	// );
}

interface IProps {
}

interface IState {
  seletableOption?: string;
	clearable?: boolean;
	team_score?: number;
	team_names?: Array<any>;
}

class Scorer extends Component<IProps, IState> {

	constructor(props:any) {
		super(props);

		this.state = {
			seletableOption: '',
			clearable: true,
			team_score: 0,
			team_names: [],
		}
	}

	componentDidMount() {
		let fll_display:any = document.getElementById("fll_teams_list");
		// let teams:any[] = [];

		


		// console.log(teams);
		// this.setState({
		// 	team_names: initialTeams,
		// });

		console.log(this.state.team_names);
	}

	handleChange(team_options:string) {
		this.setState({seletableOption: team_options});
	}

	handleSubmit() {

	}

	handleTeamNumber(e:any) {
		var teamOptions = fetch(get_teams_request)
		.then((response) => {
			return response.json();
		}).then(data => {
			let teamOptions = data.map(function (team:any) {
				// console.log(team);
				// return {value: team.team_name, label: team.team_name};
				// if ()
				return teamOptions;
			});

			// console.log(returner);
			return teamOptions;
			
		}).catch((error) => {
			console.log(error);
		});

		return teamOptions;
	}

	render() {
		// let teamOptions = this.state.team_names?.map(function (name) {
		// 	return name.team_name;
		// });

		// console.log(this.state.team_names);

		// console.log(teamOptions);

		return (
			<div className="Login">
			<form onSubmit={this.handleSubmit}>
				<label>Rank Number</label>
				<Select
					// onChange={(e:any) => onScoreChange(e.value)}
					// options={teams}
				/>
				<label>Team Number</label><br/>
				<input type="text" onChange={e => this.handleTeamNumber(e.target.value)}/>
				<div>
					<button className="buttonGreen" type="submit">Submit</button>
				</div>

				<div id="team_disp">

				</div>
			</form>
		</div>
	
		);
	}

}

export default Scorer;