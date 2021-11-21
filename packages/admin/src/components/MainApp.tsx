import React, { useCallback, } from "react";
import Axios from 'axios';
import {useDropzone} from 'react-dropzone';
import Papa from 'papaparse';
import { readFileSync } from "fs";

import './admin.css'


const request = "http://" + window.location.hostname + ":3001/api";

const setup_database = request + "/database/setup"; 
const new_teams = request + "/teams/new"; 

function wait(ms:any) {
	return new Promise((resolve) => {setTimeout(resolve, ms)});
}

const sendTeams = async (csv_data:any) => {
	// const row = csv_data.data.map();

	const iterator = csv_data.data;

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

function TeamsDropzone() {
	const onDrop = useCallback((acceptedFiles) => {
		acceptedFiles.forEach((file:any) => {
			const reader = new FileReader()
			
			// let reader = file.body.getReader();
			// let decoder = new TextDecoder('utf-8');

			
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
			<p>Drag 'n' drop some files here, or click to select files</p>
		</div>
	)
}

function MainApp() {
	return(
		<div>
			<br/>
			<br/>
			<br/>
			<button>Setup/Purge Database</button>
			<br/>
			<br/>
			<TeamsDropzone/>
		</div>
	);
}

export default MainApp;