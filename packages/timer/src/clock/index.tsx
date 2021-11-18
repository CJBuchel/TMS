import React, { useState } from 'react'

import Axios from 'axios';
import './index.css'
import { onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockStartEvent, onClockTimeEvent } from '../comm_service';

// const clockRequest = "http://localhost"
const clockRequest = "http://" + window.location.hostname + ":3001/api/clock";


function pad (number: any, length: any) {
	return (new Array(length + 1).join('0') + number).slice(-length)
}

function parseTime (time: number) {
	if (time <= 30) {
		return `${time | 0}`
	} else {
		return `${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`
	}
}

export default function Clock (props: any) {
	const [buttonsDisabled, setButtonsDisabled] = useState(false);

	const [timerState, setState] = useState(''); // {armed, prerunning, running, ended}
	const [currentTime, setTime] = useState(0);

	const _removeSubscriptions = [];

	function postTimerControl(e:string) {
		setButtonsDisabled(true);
		Axios.post(clockRequest+"/"+e);
		setTimeout(() => setButtonsDisabled(false), 2000);
	}


	function setPrestart() {postTimerControl("prestart")}
	function setStart() {postTimerControl("start")}
	function setStop() {postTimerControl("stop")}
	function setReload() {postTimerControl("reload")}

	onClockPrestartEvent(() => {
		setState('prerunning');
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockStartEvent(() => {
		setState('running');
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockTimeEvent(({time}:{time:any}) => {
		setTime(time);
		console.log(time);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockEndGameEvent(() => {
		setState('armed');
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});
	
	onClockEndEvent(() => {
		setState('ended');
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	return (
		<div>
			<div className={`clock ${timerState}`}>
				{ parseTime(currentTime) }
			</div>
			<div className='timer_controls'>
					<button className="hoverButton green" onClick={setStart} disabled={buttonsDisabled}>Start</button>
					<button className="hoverButton orange" onClick={setPrestart} disabled={buttonsDisabled}>Pre Start</button>
			</div>
		</div>
	)
}