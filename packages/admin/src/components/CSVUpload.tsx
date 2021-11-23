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

const sendTeams = async (csv_data:any) => {
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

const sendSchedule = async (csv_data:any) => {
	await Axios.post(new_schedule, {
		schedule_data: csv_data
	}).then(response => {
		console.log(response);
		alert(response.data.message);
		sendScoreUpdate("new_teams_update");
	}).catch((error) => {
		alert("Error: " + error);
		console.log(error);
	});
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

				<button className="hoverButton orange">Click to import CSV [number, name, school]</button>
				{/* <p>Drag 'n' drop some files here, or click to select files</p> */}
			</div>
		</div>
	)
}

function ScheduleDropzone() {
	const onDrop = useCallback((acceptedFiles) => {
		acceptedFiles.forEach((file:any) => {
			const reader = new FileReader()
			
			reader.onabort = () => console.log('file reading was aborted')
			reader.onerror = () => console.log('file reading has failed')
			reader.onload = () => {
			// Do whatever you want with the file contents
				const csv:any = reader.result;
				const csv_result = Papa.parse(csv, {header: false});

				console.log(csv_result);
				
				sendSchedule(csv_result);
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

				<button className="hoverButton orange">Click to import Schedule CSV [match number, time, team number]</button>
				{/* <p>Drag 'n' drop some files here, or click to select files</p> */}
			</div>
		</div>
	)
}

interface IProps {

}

interface IState {

}

class CSVUpload extends React.Component<IProps, IState> {
	constructor(props:any) {
		super(props);

		this.state = {

		}
	}

	render() {
		return (
			<div>
				<TeamsDropzone/>
				<ScheduleDropzone/>
			</div>
		);
	}
}

export default CSVUpload;