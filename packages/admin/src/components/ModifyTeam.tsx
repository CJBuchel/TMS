import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";
import { sendEvent, sendScoreUpdate } from "../comm_service";
import Select from 'react-select';

import './admin.css'

const request = "http://" + window.location.hostname + ":3001/api";
const modify_team = request + "/team/modify";

interface IProps {
	team_arr?: any;
}

interface IState {
	modifyTeam?: boolean;

	rank_number?: number;
	team_number?: string;

	team_score?: number;
	team_gp?: string;
	team_name?: any;
	team_notes?: any;

	// Team

	// Modify states
	team_modify_number?: string;
	team_modify_score?: number;
	team_modify_name?: any;
	team_modify_affiliation?: any;
	
	team_modify_notes_1?: any;
	team_modify_notes_2?: any;
	team_modify_notes_3?: any;
	
	team_modify_gp_1?: string;
	team_modify_gp_2?: string;
	team_modify_gp_3?: string;

	team_modify_score1?: number;
	team_modify_score2?: number;
	team_modify_score3?: number;
}

class ModifyTeams extends React.Component<IProps, IState> {
	constructor(props:any) {
		super(props);

		this.state = {
			modifyTeam: false,
		}

		this.ShowModifyTeams = this.ShowModifyTeams.bind(this);
	}

	// Sending/Recv
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

	handleClear(e:any) {
		this.setState({rank_number: 0, team_score: 0, team_name: null, team_number: " ", team_gp: " ", team_notes: " "});
		window.location.reload();
	}

	handleTeamChange(team:any) {
		this.setState({team_name: team});
	}

	// --------------------------- Modify Team handles ---------------------
	handleModifyTeamNumber(number:any) {
		this.setState({team_modify_number: number});
	}

	handleModifyTeamChange(team:any) {
		this.setState({team_modify_name: team});
	}

	handleModifyTeamAffiliationChange(aff:any) {
		this.setState({team_modify_affiliation: aff});
	}

	handleModifyGPChange1(gp:string) {
		this.setState({team_modify_gp_1: gp});
	}

	handleModifyGPChange2(gp:string) {
		this.setState({team_modify_gp_2: gp});
	}

	handleModifyGPChange3(gp:string) {
		this.setState({team_modify_gp_3: gp});
	}

	handleModifyScoreChange1(score:number) {
		this.setState({team_modify_score1: score});
	}

	handleModifyScoreChange2(score:number) {
		this.setState({team_modify_score2: score});
	}

	handleModifyScoreChange3(score:number) {
		this.setState({team_modify_score3: score});
	}

	handleModifyNotesChange1(notes:any) {
		this.setState({team_modify_notes_1: notes});
	}

	handleModifyNotesChange2(notes:any) {
		this.setState({team_modify_notes_2: notes});
	}

	handleModifyNotesChange3(notes:any) {
		this.setState({team_modify_notes_3: notes});
	}


	handleModifySubmit(e:any) {
		const submission = {
			original_team: this.state.team_name,
			number: this.state.team_modify_number,
			name: this.state.team_modify_name,
			aff: this.state.team_modify_affiliation,

			score1: this.state.team_modify_score1,
			score2: this.state.team_modify_score2,
			score3: this.state.team_modify_score3,

			gp1: this.state.team_modify_gp_1,
			gp2: this.state.team_modify_gp_2,
			gp3: this.state.team_modify_gp_3,

			notes1: this.state.team_modify_notes_1,
			notes2: this.state.team_modify_notes_2,
			notes3: this.state.team_modify_notes_3,
		}
		console.log(submission);
		this.sendTeamData(modify_team, submission);
		sendScoreUpdate(this.state.team_name);
	}

	displayModifyTeam(show:boolean) {
		this.setState({modifyTeam: show});
		if (!show) {
			this.handleClear("");
		}
	}

	ShowModifyTeams() {
		return(
			<div className="teamAddition">
				<label>Select Team</label>
				<Select
					onChange={(e:any) => this.handleTeamChange(e)}
					options={this.props.team_arr}
				/>

				{/* General */}
				<div className="modifyGeneral">
					<label>Change Team Number</label>
					<input type="text" onChange={(e:any) => this.handleModifyTeamNumber(e.target.value)}/>
					<label>Change Team Name</label>
					<input type="text" onChange={(e:any) => this.handleModifyTeamChange(e.target.value)}/>
					<label>Change Team Affiliation</label>
					<input type="text" onChange={(e:any) => this.handleModifyTeamAffiliationChange(e.target.value)}/>
				</div>

				{/* Ranks */}
				<div className="modifyRank1">
					<label>Change Team Rank 1 Score</label>
					<input type="text" onChange={(e:any) => this.handleModifyScoreChange1(e.target.value)}/>
					<label>Change Team Rank 1 GP</label>
					<input type="text" onChange={(e:any) => this.handleModifyGPChange1(e.target.value)}/>
					<label>Change Team Rank 1 Notes</label>
					<input type="text" onChange={(e:any) => this.handleModifyNotesChange1(e.target.value)}/>
				</div>
				
				<div className="modifyRank2">
					<label>Change Team Rank 2 Score</label>
					<input type="text" onChange={(e:any) => this.handleModifyScoreChange2(e.target.value)}/>
					<label>Change Team Rank 2 GP</label>
					<input type="text" onChange={(e:any) => this.handleModifyGPChange2(e.target.value)}/>
					<label>Change Team Rank 2 Notes</label>
					<input type="text" onChange={(e:any) => this.handleModifyNotesChange2(e.target.value)}/>
				</div>

				<div className="modifyRank2">
					<label>Change Team Rank 3 Score</label>
					<input type="text" onChange={(e:any) => this.handleModifyScoreChange3(e.target.value)}/>
					<label>Change Team Rank 3 GP</label>
					<input type="text" onChange={(e:any) => this.handleModifyGPChange3(e.target.value)}/>
					<label>Change Team Rank 3 Notes</label>
					<input type="text" onChange={(e:any) => this.handleModifyNotesChange3(e.target.value)}/>
				</div>
			</div>
		);
	}

	render() {
		return(
			<div>
				<h3>Modify Team</h3>
				{!this.state.modifyTeam && <button onClick={e => this.displayModifyTeam(true)} className="hoverButton green">Modify</button>}
				{ this.state.modifyTeam && <this.ShowModifyTeams/> }
				{this.state.modifyTeam && <button onClick={e => this.handleModifySubmit(e)} className="hoverButton green">Modify</button>}
				{this.state.modifyTeam && <button onClick={e => this.displayModifyTeam(false)} className="hoverButton orange">Close</button>}
			</div>
		);
	}
}

export default ModifyTeams;