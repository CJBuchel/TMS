import React from 'react';
import ReactDOM from 'react-dom';
import reportWebVitals from './reportWebVitals';
import {Login, useToken} from '@cj/shared';

import './main.css';

import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import {
	sendClockEndEvent,
	sendClockEndgameEvent,
	sendClockPrestartEvent,
	sendClockReload,
	sendClockStartEvent,
	sendClockStopEvent,
	sendClockTimeEvent,
	sendEvent
} from "./comm_service";

import {
	onClockEndEvent,
	onClockEndGameEvent,
	onClockPrestartEvent,
	onClockReloadEvent,
	onClockStartEvent,
	onClockStopEvent,
	onClockTimeEvent
} from "./comm_service";

import ReactResizeDetector from 'react-resize-detector';

import Clock from './clock'
import Sound from './sound'


function App() {
	const { token, setToken } = useToken();

	if (!token) {
		console.log("Token not made, redirecting")
		return <Login setToken={setToken}/>
	}

	return (
		<div id='main-container' className={`ui centered grid ${0 ? 'fullscreen' : ''}`}>
			<Clock status={0} time={100} format={'seconds'} />
		</div>
	);
}

export default App;

ReactDOM.render(
	<App/>,
	document.getElementById('root')
);