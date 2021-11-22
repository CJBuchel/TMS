import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";
import { sendEvent, sendScoreUpdate } from "../comm_service";
import Select from 'react-select';

import './admin.css'

interface IProps {
	team_arr?: any;
}

interface IState {
	// Team
	team_name?: string;

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

		} 
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

	render() {
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
}

