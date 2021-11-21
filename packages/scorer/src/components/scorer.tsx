import Select from 'react-select';
import React, { Component, useState } from "react";
import PropTypes from 'prop-types';

import "./scorer.css"

import Axios from 'axios';
import { IndexRouteProps } from 'react-router';
import { sendScoreUpdate } from '../comm_service';

const request = "http://" + window.location.hostname + ":3001/api";
const get_teams_request = request+"/teams/get";
const post_score_request = request+"/teams/score";


const rankOptions = [
	{value: 1, label: 'Rank 1'},
	{value: 2, label: 'Rank 2'},
	{value: 3, label: 'Rank 3'},
]

const GP_Options = [
	{value: "Beginning", label: 'Beginning'},
	{value: "Developing", label: 'Developing'},
	{value: "Accomplished", label: 'Accomplished'},
	{value: "Exceeds", label: 'Exceeds'},
]

interface IProps {
}

interface IState {
	rank_number?: number;
	team_number?: string;

	team_score?: number;
	team_gp?: string;
	team_name?: any;
	team_notes?: any;

	team_arr?: Array<any>;
}

class Scorer extends Component<IProps, IState> {

	constructor(props:any) {
		super(props);

		this.state = {
			rank_number: undefined, // Can only be 1,2,3 => i put 0 there so scorers will get error if they submit wrong... coz i know they will
			
			team_number: undefined,
			team_score: undefined,
			team_name: undefined,
			team_gp: undefined,
			team_notes: undefined,

			team_arr: [],
		}
	}

	componentDidMount() {
		// this.setState({team_options: ['wonderbats', 'this and that', 'test 3']})
		let teams:any = [];
		fetch(get_teams_request)
		.then((response) => {
			return response.json();
		}).
		then((data) => {
			for (const team of data) {
				teams.push({value: team.team_name, label: team.team_name, number: team.team_number});
			}

			this.setState({team_arr: teams});
		})
	}

	handleTeamChange(team:any) {
		// for (const)
		this.setState({team_number: team?.number});
		this.setState({team_name: team?.value});
	}

	handleRankChange(rankNumber:number) {
		this.setState({rank_number: rankNumber});
	}

	handleGPChange(gp:string) {
		this.setState({team_gp: gp});
	}

	handleNotesChange(notes:any) {
		this.setState({team_notes: notes});
	}

	handleScoreChange(score:number) {
		this.setState({team_score: score});
	}

	async sendTeamData(data:any) {
		// e.preventDefaults();

		await fetch(post_score_request, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},

			body: JSON.stringify(data)
		}).then(response => {
			return response.json();
		}).then(data => {
			console.log(data)
			alert(data.message);
		});
	}


	handleSubmit(e:any, name:any, rank:any, score:any, gp:any, notes:any) {
		this.sendTeamData({name, rank, score, gp, notes})
		sendScoreUpdate(name);
	}

	handleClear(e:any) {
		this.setState({rank_number: 0, team_score: 0, team_name: null, team_number: " ", team_gp: " ", team_notes: " "});
		window.location.reload();
	}


	render() {
		return (
			<div className="Login">
					<div className="inputs">

						{/* Inputs */}
						<label>Rank Number</label>
						<Select
							name="Select Rank"
							onChange={(e:any) => this.handleRankChange(e.value)}
							options={rankOptions}
						/>

						<label>Team Name</label>
						<Select
							onChange={(e:any) => this.handleTeamChange(e)}
							options={this.state.team_arr}
						/>

						<label>Score</label>
						<input type="number" onChange={e => this.handleScoreChange(parseFloat(e.target.value))}/>

						<label>GP (Only seen by admins and judges)</label>
						<Select
							name="Select GP"
							onChange={(e:any) => this.handleGPChange(e.value)}
							options={GP_Options}
						/>

						<label>Notes on Team (Only seen by admins and judges)</label>
						<input type="text" onChange={e => this.handleNotesChange(e.target.value)}/>

						{/* Clear button */}
						<div className="clearData">
							<button type="reset" className="hoverButton red" onClick={e=>this.handleClear(e)}>Clear</button>
						</div>

						{/* Options */}
						<div className="scorer-options">
							<label>Chosen Options:</label>
							<li className="scorer-options">
								<ul>- Team Number: [<span className="green-text">{this.state.team_number}</span>]</ul>
								<ul>- Team Name: [<span className="green-text">{this.state.team_name}</span>]</ul>
								<ul>- Rank Number: [<span className="green-text">{this.state.rank_number}</span>]</ul>
								<ul>- GP: [<span className="green-text">{this.state.team_gp}</span>]</ul>
								<ul>- Final Score: [<span className="green-text">{this.state.team_score}</span>]</ul>
							</li>
						</div>

						<div>
							<div className="red-text">CHECK THESE VALUES BEFORE SUBMITTING</div>
							<button className="buttonGreen" onClick={e=>this.handleSubmit(e, this.state.team_name, this.state.rank_number, this.state.team_score, this.state.team_gp, this.state.team_notes)}>Submit</button>
						</div>

					</div>
			</div>
		);
	}

}

export default Scorer;