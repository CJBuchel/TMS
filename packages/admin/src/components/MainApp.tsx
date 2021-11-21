import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";
import { sendScoreUpdate } from "../comm_service";
import Select from 'react-select';

import './admin.css'


const request = "http://" + window.location.hostname + ":3001/api";

const purge_database = request + "/database/purge";
const new_teams = request + "/teamset/new";
const new_team = request + "/team/new";
const modify_team = request + "/team/modify";
const get_teams_request = request+"/teams/get";
const post_score_request = request+"/teams/score";

const GP_Options = [
	{value: "Beginning", label: 'Beginning'},
	{value: "Developing", label: 'Developing'},
	{value: "Accomplished", label: 'Accomplished'},
	{value: "Exceeds", label: 'Exceeds'},
]

const sendTeams = async (csv_data:any) => {
	// const row = csv_data.data.map();

	await Axios.post(new_teams, {
		teams_data: csv_data
	}).then(response => {
		console.log(response);
		alert(response.data.message);
		sendScoreUpdate("new_teams_update");
	}).catch((error) => {
		alert("Error: " + error);
		console.log(error);
	});
}

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

function TeamsDropzone() {
	const onDrop = useCallback((acceptedFiles) => {
		acceptedFiles.forEach((file:any) => {
			const reader = new FileReader()
			
			reader.onabort = () => console.log('file reading was aborted')
			reader.onerror = () => console.log('file reading has failed')
			reader.onload = () => {
			// Do whatever you want with the file contents
				const csv:any = reader.result;
				const csv_result = Papa.parse(csv, {header: false});
				
				sendTeams(csv_result);
			}
			// reader.readAsArrayBuffer(file)
			reader.readAsText(file);
		})
	}, [])
	const {getRootProps, getInputProps} = useDropzone({onDrop})

	return (
		<div>

			<div {...getRootProps()}>
				<input {...getInputProps()} />

				<button className="hoverButton green">Click to import CSV [number, name, school]</button>
				{/* <p>Drag 'n' drop some files here, or click to select files</p> */}
			</div>
		</div>
	)
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
	modifyTeam?: boolean;

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
			modifyTeam: false,

			team_arr: [],
		}

		this.ShowAddTeam = this.ShowAddTeam.bind(this);
		this.ShowModifyTeam = this.ShowModifyTeam.bind(this);
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

	displayModifyTeam(show:boolean) {
		this.setState({modifyTeam: show});
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

	ShowModifyTeam() {
		return (
			<div className="teamAddition">
				<label>Select Team</label>
				<Select
					onChange={(e:any) => this.handleTeamChange(e)}
					options={this.state.team_arr}
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
			<div className="row">
				<div className="column">
					<div>
						<h1>Admin Controls</h1>
						<button onClick={purgeTeams} className="hoverButton red">Setup/Purge Database</button>
						<h3>CSV Control</h3>
						<TeamsDropzone/>
						<h3>Display Controls</h3>
						<button onClick={updateDisplay} className="hoverButton green">Force Update Display</button>
					</div>
				</div>
				<div className="column">
					<h1>Team Controls</h1>
		
					<h3>Add Team</h3>
					{!this.state.teamAdd && <button onClick={e => this.displayAddTeam(true)} className="hoverButton green">Add Team</button>}
					{ this.state.teamAdd && <this.ShowAddTeam/> }
					{this.state.teamAdd && <button onClick={e => this.handleSubmit(e, this.state.team_number, this.state.team_name, this.state.team_affiliation)} className="hoverButton green">Submit</button>}
					{this.state.teamAdd && <button onClick={e => this.displayAddTeam(false)} className="hoverButton orange">Close</button>}

					<h3>Modify Team</h3>
					{!this.state.modifyTeam && <button onClick={e => this.displayModifyTeam(true)} className="hoverButton green">Modify</button>}
					{ this.state.modifyTeam && <this.ShowModifyTeam/> }
					{this.state.modifyTeam && <button onClick={e => this.handleModifySubmit(e)} className="hoverButton green">Modify</button>}
					{this.state.modifyTeam && <button onClick={e => this.displayModifyTeam(false)} className="hoverButton orange">Close</button>}
				</div>
			</div>
		);
	}
}

export default MainApp;