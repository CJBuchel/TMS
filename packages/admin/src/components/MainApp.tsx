import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";

import './admin.css'


const request = "http://" + window.location.hostname + ":3001/api";

const purge_database = request + "/database/purge"; 
const new_teams = request + "/teams/new"; 

const sendTeams = async (csv_data:any) => {
	// const row = csv_data.data.map();

	Axios.post(new_teams, {
		teams_data: csv_data
	}).then((response) => {
		// alert(response);
		console.log(response);
	}).catch((error) => {
		alert("Error: " + error);
		console.log(error);
	})
}

const purgeTeams = async () => {
	await fetch(purge_database)
	.then(response => {
		return response.json();
	}).then(data => {
		console.log(data)
		alert(data.message);
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
		<div {...getRootProps()}>
			<input {...getInputProps()} />
			<button className="hoverButton green">Click to import CSV [number, name, school]</button>
			{/* <p>Drag 'n' drop some files here, or click to select files</p> */}
		</div>
	)
}

function MainApp() {
	return(
		<div className="center centerContent">
			<h1>Admin</h1>
			<button onClick={purgeTeams} className="hoverButton red">Setup/Purge Database</button>
			<h3>CSV Control</h3>
			<TeamsDropzone/>
		</div>
	);
}

export default MainApp;