import React, { useState } from 'react'

import Axios from 'axios';
import './index.css'
import { onSystemRefreshEvent, onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockReloadEvent, onClockStartEvent, onClockStopEvent, onClockTimeEvent, sendClockPrestartEvent } from '../comm_service';

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

	const [main_config, setMainCfg] = useState(true);
	const [running_config, setRunningCfg] = useState(false);
	const [stopped_config, setStoppedCfg] = useState(false);


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

	onSystemRefreshEvent(() => {
		setStop();
		window.location.reload();
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockPrestartEvent(() => {
		setState('prerunning');
		setMainCfg(false);
		setRunningCfg(true);
		setStoppedCfg(false);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockStartEvent(() => {
		setState('running');
		setMainCfg(false);
		setRunningCfg(true);
		setStoppedCfg(false);
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
		setMainCfg(false);
		setRunningCfg(true);
		setStoppedCfg(false);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});
	
	onClockEndEvent(() => {
		setState('ended');
		setMainCfg(false);
		setRunningCfg(false);
		setStoppedCfg(true);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockStopEvent(() => {
		setState('ended');
		setMainCfg(false);
		setRunningCfg(false);
		setStoppedCfg(true);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockReloadEvent(() => {
		setState('running');
		setTime(150);
		setMainCfg(true);
		setRunningCfg(false);
		setStoppedCfg(false);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	const MainConfig = () => (
		<div id='main_config' className='timer_controls'>
				<button className="hoverButton green" onClick={setStart} disabled={buttonsDisabled}>Start</button>
				<button className="hoverButton orange" onClick={setPrestart} disabled={buttonsDisabled}>Pre Start</button>
		</div>
	)

	const RunningConfig = () => (
		<div id='running_config' className='timer_controls'>
			<button className="hoverButton red" onClick={setStop} disabled={buttonsDisabled}>Abort</button>
		</div>
	)

	const StoppedConfig = () => (
		<div id='stopped_config' className='timer_controls'>
			<button className="hoverButton orange" onClick={setReload} disabled={buttonsDisabled}>Reload</button>
		</div>
	)

	return (
		<div>
			<div className={`clock ${timerState}`}>
				{ parseTime(currentTime) }
			</div>


				{running_config && !buttonsDisabled && <RunningConfig/>}
				{stopped_config && !buttonsDisabled && <StoppedConfig/>}
				{main_config && !buttonsDisabled && <MainConfig/>}
		

		</div>
	)
}