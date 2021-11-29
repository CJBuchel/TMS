import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";
import { sendEvent, sendScoreUpdate } from "../comm_service";
import ModifyTeams from "./ModifyTeam";
import CSVUpload from "./CSVUpload"
import PasswordChange from "./PasswordChange";
import Select from 'react-select';

import './admin.css'


const request = "http://" + window.location.hostname + ":3001/api";

const purge_database = request + "/database/purge";
const new_teams = request + "/teamset/new";
const new_team = request + "/team/new";
const get_teams_request = request + "/teams/get";
const update_ranks = request + "/teams/updateRanking";

const purgeTeams = async () => {
	await fetch(purge_database)
	.then(response => {
		return response.json();
	}).then(data => {
		console.log(data)
		sendScoreUpdate("new_teams_update");
		alert(data.message);
	});
}

const updateDisplay = async () => {
	sendScoreUpdate("admin_update");
	console.log("Display force update")
}

const refreshDisplays = async () => {
	sendEvent("cj_node", "system:refresh");
}

interface IProps {
}

interface IState {
  rank_number?: number;
	team_number?: string;

	team_score?: number;
	team_gp?: string;
	team_name?: any;
	team_notes?: any;
	team_affiliation?: any;

	team_arr?: Array<any>;

	teamAdd?: boolean;
}

class MainApp extends React.Component<IProps, IState> {
	constructor(props:any) {
		super(props);

		this.state = {
			rank_number: undefined, // Can only be 1,2,3 => i put 0 there so scorers will get error if they submit wrong... coz i know they will
			
			team_number: undefined,
			team_score: undefined,
			team_name: undefined,
			team_gp: undefined,
			team_notes: undefined,
			team_affiliation: undefined,

			teamAdd: false,
			// modifyTeam: false,

			team_arr: [],
		}

		this.ShowAddTeam = this.ShowAddTeam.bind(this);
		// this.ShowModifyTeam = this.ShowModifyTeam.bind(this);
	}

	componentDidMount() {
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

	// ------------------------- Team Handles -------------------------------
	handleTeamNumber(number:any) {
		this.setState({team_number: number});
	}

	handleTeamChange(team:any) {
		this.setState({team_name: team});
	}

	handleTeamAffiliationChange(aff:any) {
		this.setState({team_affiliation: aff});
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

	async sendTeamData(request:any, data:any) {

		await fetch(request, {
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


	handleSubmit(e:any, number:any, name:any, aff:any) {
		this.sendTeamData(new_team, {number, name, aff})
		sendScoreUpdate(name);
	}

	handleClear(e:any) {
		this.setState({rank_number: 0, team_score: 0, team_name: null, team_number: " ", team_gp: " ", team_notes: " "});
		window.location.reload();
	}

	displayAddTeam(show:boolean) {
		this.setState({teamAdd: show});
		if (!show) {
			this.handleClear("");
		}
	}

	ShowAddTeam() {
		return (
			<div className="teamAddition">
				<label>Team Number</label>
				<input type="text" onChange={(e:any) => this.handleTeamNumber(e.target.value)}/>
				<label>Team Name</label>
				<input type="text" onChange={(e:any) => this.handleTeamChange(e.target.value)}/>
				<label>Affiliation</label>
				<input type="text" onChange={(e:any) => this.handleTeamAffiliationChange(e.target.value)}/>
			</div>
		);
	}

	render() {
		return(
			<div className="row">
				<div className="column">
					<div>
						<h1>Admin Controls</h1>
						<button onClick={purgeTeams} className="hoverButton red">Setup/Purge Database</button>
						<h3>CSV Control</h3>
						<CSVUpload/>
						<h3>Display Controls</h3>
						<button onClick={updateDisplay} className="hoverButton green">Force Update Display</button>
						<button onClick={e => this.sendTeamData(update_ranks, {})} className="hoverButton green">Force Update Rankings</button>
						<h3>System Controls</h3>
						<button onClick={refreshDisplays} className="hoverButton red">Force Reload All Pages</button>
						<h3>Change User Passwords</h3>
						<PasswordChange/>
					</div>
				</div>
				<div className="column">
					<h1>Team Controls</h1>
		
					<h3>Add Team</h3>
					{!this.state.teamAdd && <button onClick={e => this.displayAddTeam(true)} className="hoverButton green">Add Team</button>}
					{this.state.teamAdd && <this.ShowAddTeam/>}
					{this.state.teamAdd && <button onClick={e => this.handleSubmit(e, this.state.team_number, this.state.team_name, this.state.team_affiliation)} className="hoverButton green">Submit</button>}
					{this.state.teamAdd && <button onClick={e => this.displayAddTeam(false)} className="hoverButton orange">Close</button>}
					<ModifyTeams team_arr={this.state.team_arr}/>
				</div>
			</div>
		);
	}
}

export default MainApp;