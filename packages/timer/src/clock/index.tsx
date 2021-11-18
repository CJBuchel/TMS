import React, { Component, useState } from 'react'

import Axios from 'axios';
import './index.css'
import { onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockStartEvent, onClockTimeEvent } from '../comm_service';
import { Interface } from 'readline';

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

interface IProps {

}

interface IState {
	_removeSubscriptions: [];
	buttonsDisabled: boolean;
	timerState: string;
	currentTime: number;
}

const _removeSubscriptions = [];
export default class Clock extends Component<IProps, IState> {
	constructor(props:any) {
		super(props)

		this.state = {
			_removeSubscriptions: [],
			buttonsDisabled: false,
			timerState: '',
			currentTime: 0
		}
	}

	componentDidMount () {
		onClockPrestartEvent(() => {
			this.setState({timerState: 'prerunning'})
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
	
		onClockStartEvent(() => {
			this.setState({timerState: 'running'})
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
	
		onClockTimeEvent(({time}:{time:any}) => {
			this.setState({currentTime: time})
			console.log(time);
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
	
		onClockEndGameEvent(() => {
			this.setState({timerState: 'armed'})
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
		
		onClockEndEvent(() => {
			this.setState({timerState: 'ended'})
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
	}

	postTimerControl(e:string) {
		this.setState({buttonsDisabled: true})
		Axios.post(clockRequest+"/"+e);
		setTimeout(() => this.setState({buttonsDisabled: false}), 2000);
	}


	setPrestart() {this.postTimerControl("prestart")}
	setStart() {this.postTimerControl("start")}
	setStop() {this.postTimerControl("stop")}
	setReload() {this.postTimerControl("reload")}

	getTimerState() { return  }

	render () {
		return (
			<div>
				<div className={`clock ${this.state.timerState}`}>
					{ parseTime(this.state.currentTime) }
				</div>
				<div className='timer_controls'>
						<button className="hoverButton green" onClick={this.setStart} disabled={this.state.buttonsDisabled}>Start</button>
						<button className="hoverButton orange" onClick={this.setPrestart} disabled={this.state.buttonsDisabled}>Pre Start</button>
				</div>
			</div>
		);
	}
}