import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";
import { sendEvent, sendScoreUpdate } from "../comm_service";
import ModifyTeams from "./ModifyTeam";
import Select from 'react-select';

import './admin.css'

const request = "http://" + window.location.hostname + ":3001/api";
const new_teams = request + "/teamset/new";
const new_schedule = request + "/scheduleset/new";

const sendTeams = async (teams:any) => {
	await Axios.post(new_teams, {
		teams_data: teams
	}).then(response => {
		console.log(response);
		alert(response.data.message);
		sendScoreUpdate("new_teams_update");
	}).catch((error) => {
		alert("Error: " + error);
		console.log(error);
	});
}

const sendSchedule = async (schedule:any) => {
	await Axios.post(new_schedule, {
		schedule_data: schedule
	}).then(response => {
		console.log(response);
		alert(response.data.message);
		sendScoreUpdate("new_teams_update");
	}).catch((error) => {
		alert("Error: " + error);
		console.log(error);
	});
}

function processCSV(csv:any) {
	const teams:any[] = [];
	const matches:any[] = [];
	const tables:any[] = [];

	var rowStartTeams;
	var rowEndTeams;

	var rowStartSchedule;
	var rowEndSchedule;

	var numberOfTeams;
	var numberOfMatches;
	var numberOfTables;

	for (var i = 0; i < csv.data.length; i++) {
		var row = csv.data[i];
		if (row[0] == 'Number of Teams') {
			numberOfTeams = parseInt(row[1]);
			rowStartTeams = i+1;
			rowEndTeams = i+parseInt(row[1]);
		}

		if (row[0] == 'Number of Ranking Matches') {
			numberOfMatches = parseInt(row[1]);
		}
		
		if (row[0] == 'Number of Tables') {
			numberOfTables = parseInt(row[1]);
		}
		
		if (row[0] == 'Table Names') {
			for (var j = 1; j < (numberOfTables||0)+1; j++) {
				tables.push({table: row[j]});
			}
	
			rowStartSchedule = i+1;
			rowEndSchedule = (i+(numberOfMatches||0));
		}
	}

	for (var ii = (rowStartTeams||0); ii <= (rowEndTeams||0); ii++) {
		teams.push(csv.data[ii]);
	}

	for (var iii = (rowStartSchedule||0); iii <= (rowEndSchedule||0); iii++) {
		matches.push(csv.data[iii]);
	}

	const schedule = {tables: tables, matches: matches};

	sendTeams(teams);
	sendSchedule(schedule);
}

function ScoringImport() {
	const onDrop = useCallback((acceptedFiles) => {
		acceptedFiles.forEach((file:any) => {
			const reader = new FileReader()
			
			reader.onabort = () => console.log('file reading was aborted')
			reader.onerror = () => console.log('file reading has failed')
			reader.onload = () => {
			// Do whatever you want with the file contents
				const csv:any = reader.result;
				const csv_result = Papa.parse(csv, {header: false});
				
				processCSV(csv_result);
				// console.log(csv_result);
				// sendTeams(csv_result);
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

				<button className="hoverButton orange">Click to import CSV</button>
				{/* <p>Drag 'n' drop some files here, or click to select files</p> */}
			</div>
		</div>
	)
}


interface IProps {}
interface IState {}

class CSVUpload extends React.Component<IProps, IState> {
	constructor(props:any) {
		super(props);
		
		this.state = {}
	}

	render() {
		return (
			<div>
				<ScoringImport/>
				{/* <TeamsDropzone/> */}
				{/* <ScheduleDropzone/> */}
			</div>
		);
	}
}

export default CSVUpload;