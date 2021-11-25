import React, { Component, useState } from 'react'

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

const _removeSubscriptions = [];

const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3");
const endAudio = new window.Audio("./sounds/end.mp3");

interface IProps {

}

interface IState {
	soundsEnabled?: boolean;

	buttonsDisabled?: boolean;

	timerState?: string;
	currentTime?: number;

	mainConfigState?: boolean;
	runningConfigState?: boolean;
	stoppedConfigState?: boolean;
}

class Clock extends Component<IProps,IState> {
	constructor(props:any) {
		super(props);

		onSystemRefreshEvent(() => {
			console.log("refresh event");
			this.setStop();
			window.location.reload();
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockPrestartEvent(() => {
			this.setState({timerState: 'prerunning'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: true});
			this.setState({stoppedConfigState: false});
		});

		onClockStartEvent(() => {
			this.setState({timerState: 'running'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: true});
			this.setState({stoppedConfigState: false});
			this.playSoundsIfEnabled(startAudio);
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockEndGameEvent(() => {
			this.setState({timerState: 'armed'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: true});
			this.setState({stoppedConfigState: false});
			this.playSoundsIfEnabled(endGameAudio);
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockEndEvent(() => {
			this.setState({timerState: 'ended'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: false});
			this.setState({stoppedConfigState: true});
			this.playSoundsIfEnabled(endAudio);
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockStopEvent(() => {
			this.setState({timerState: 'ended'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: false});
			this.setState({stoppedConfigState: true});
			this.playSoundsIfEnabled(stopAudio);
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockReloadEvent(() => {
			window.location.reload();
			this.setState({mainConfigState: true});
			this.setState({runningConfigState: false});
			this.setState({stoppedConfigState: false});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockTimeEvent(({time}:{time:number}) => {
			this.setState({currentTime: time});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		this.state = {
			soundsEnabled: true,
			mainConfigState: true,
			runningConfigState: false,
			stoppedConfigState: false,

			currentTime: 150,
		}

		this.postTimerControl = this.postTimerControl.bind(this);

		this.setPrestart = this.setPrestart.bind(this);
		this.setStart = this.setStart.bind(this);
		this.setStop = this.setStop.bind(this);
		this.setReload = this.setReload.bind(this);
	}

	playsound(audio:HTMLAudioElement) {
		audio.play()
		.catch(err => {
			console.log(err);
		});
	}

	toggleSound(isEnabled:boolean) {
		if (isEnabled) {
			this.setState({soundsEnabled: false});
		} else {
			this.setState({soundsEnabled: true});
		}
	}

	playSoundsIfEnabled(audio:HTMLAudioElement) {
		if (this.state.soundsEnabled) {
			this.playsound(audio);
		}
	}

	postTimerControl(e:string) {
		this.setState({buttonsDisabled: true});
		Axios.post(clockRequest+"/"+e);
		setTimeout(() => this.setState({buttonsDisabled: false}), 2000);
	}

	setPrestart() {this.postTimerControl("prestart")}
	setStart() {this.postTimerControl("start")}
	setStop() {this.postTimerControl("stop")}
	setReload() {this.postTimerControl("reload")}


	render() {
		const MainConfig = () => (
			<div id='main_config' className='timer_controls'>
					<button className="hoverButton green" onClick={this.setStart} disabled={this.state.buttonsDisabled}>Start</button>
					<button className="hoverButton orange" onClick={this.setPrestart} disabled={this.state.buttonsDisabled}>Pre Start</button>
			</div>
		)
	
		const RunningConfig = () => (
			<div id='running_config' className='timer_controls'>
				<button className="hoverButton red" onClick={this.setStop} disabled={this.state.buttonsDisabled}>Abort</button>
			</div>
		)
	
		const StoppedConfig = () => (
			<div id='stopped_config' className='timer_controls'>
				<button className="hoverButton orange" onClick={this.setReload} disabled={this.state.buttonsDisabled}>Reload</button>
			</div>
		)
		
		return (
			<div>
				<div className={`clock ${this.state.timerState}`}>
					{ parseTime(this.state.currentTime||0) }
				</div>


				{this.state.runningConfigState && !this.state.buttonsDisabled && <RunningConfig/>}
				{this.state.stoppedConfigState && !this.state.buttonsDisabled && <StoppedConfig/>}
				{this.state.mainConfigState && !this.state.buttonsDisabled && <MainConfig/>}
		
			</div>
		);
	}
}

export default Clock;