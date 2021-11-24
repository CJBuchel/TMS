import React, { useState } from 'react'

import Axios from 'axios';
import './index.css'
import { onSystemRefreshEvent, onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockReloadEvent, onClockStartEvent, onClockStopEvent, onClockTimeEvent, sendClockPrestartEvent } from '../comm_service';


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

// Game sounds
// const startAudio = new window.Audio('/start.mp3');
// const endAudio = new window.Audio("/end.mp3");
// const endgameAudio = new window.Audio("/end-game.mp3");
// const stopAudio = new window.Audio("/stop.mp3");

const playSound = (sound:any) => {
	// sound.play();
}

export default function Clock (props: any) {
	const [buttonsDisabled, setButtonsDisabled] = useState(false);

	const [timerState, setState] = useState(''); // {armed, prerunning, running, ended}
	const [currentTime, setTime] = useState(150);

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
		console.log("refresh event");
		setStop();
		window.location.reload();
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockPrestartEvent(() => {
		console.log("prestart event");
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
		// playSound(startAudio);
		console.log("Start event");
		setState('running');
		setMainCfg(false);
		setRunningCfg(true);
		setStoppedCfg(false);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockTimeEvent(({time}:{time:any}) => {
		// console.log("Time event")
		setTime(time);
		// console.log(time);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockEndGameEvent(() => {
		// playSound(endgameAudio);
		console.log("End game event");
		setState('armed');
		setMainCfg(false);
		setRunningCfg(true);
		setStoppedCfg(false);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});
	
	onClockEndEvent(() => {
		// playSound(endAudio);
		console.log("End event");
		setState('ended');
		setMainCfg(false);
		setRunningCfg(false);
		setStoppedCfg(true);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockStopEvent(() => {
		// playSound(stopAudio);
		console.log("Stop/Abort event");
		setState('ended');
		setMainCfg(false);
		setRunningCfg(false);
		setStoppedCfg(true);
	}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
	.catch((err:any) => {
		console.error(err)
	});

	onClockReloadEvent(() => {
		console.log("Reload event");
		// setState('running');
		window.location.reload();
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