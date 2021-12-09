import React, { Component, useState } from 'react'

import Axios from 'axios';
import './index.css'
import { onSystemRefreshEvent, onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockReloadEvent, onClockStartEvent, onClockStopEvent, onClockTimeEvent, sendClockPrestartEvent, onScheduleTTLEvent } from '../comm_service';


const request = "http://" + window.location.hostname + ":3001/api";
const clockRequest = request + "/clock";
const get_teams_request = request+"/teams/get";
const get_schedule_request = request+"/scheduleSet/get";
const get_matches_request = request+"/matches/get";

const set_next_match_request  = request+"/match/next";
const set_prev_match_request  = request+"/match/prev";
const reschedule_match_request = request+"/match/reschedule";

function pad(number: any, length: any) {
	return (new Array(length + 1).join('0') + number).slice(-length)
}

function parseTime(time:number) {
	if (time <= 30) {
		return `${time | 0}`
	} else {
		return `${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`
	}
}

function parseTTL(time:number) {
	if (time < 0) {
		return `-${pad(Math.floor(time/ 60 / 60), 2)}:${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`
	} else {
		return `+${pad(Math.floor(time/ 60 / 60), 2)}:${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`
	}
}

function setPrevMatch() {
	if (window.confirm("Are you sure?")) {
		return fetch(set_prev_match_request)
		.then((response) => {
			return response.json();
		}).then(data => {
			if (data.message) {
				alert(data.message);
			} else {
				return data;
			}
		}).catch((error) => {
			// console.log(error);
			console.log("Error while processing match request");
		});
	}
}

function setNextMatch() {
	if (window.confirm("Are you sure?")) {
		return fetch(set_next_match_request)
		.then((response) => {
			return response.json();
		}).then(data => {
			if (data.message) {
				alert(data.message);
			} else {
				return data;
			}
		}).catch((error) => {
			// console.log(error);
			console.log("Error while processing match request");
		});
	}
}

function rescheduleMatch() {
	if (window.confirm("Are you sure?")) {
		return fetch(reschedule_match_request)
		.then((response) => {
			return response.json();
		}).then(data => {
			if (data.message) {
				alert(data.message);
			} else {
				return data;
			}
		}).catch((error) => {
			// console.log(error);
			console.log("Error while processing match request");
		});
	}
}

function getTeams() {
	return fetch(get_teams_request)
	.then((response) => {
		return response.json();
	}).then(data => {
		if (data.message) {
			alert(data.message);
		} else {
			return data;
		}
	}).catch((error) => {
		console.log("Error: " + error);
	});
}

function getMatches() {
	return fetch(get_matches_request)
	.then((response) => {
		return response.json();
	}).then(data => {
		if (data.message) {
			alert(data.message);
		} else {
			return data;
		}
	}).catch((error) => {
		console.log("Error: " + error);
	});
}

function getSchedule() {
	return fetch(get_schedule_request)
	.then((response) => {
		return response.json();
	}).then(data => {
		if (data.message) {
			alert(data.message);
		} else {
			return data;
		}
	}).catch((error) => {
		console.log("Error: " + error);
	});
}

const _removeSubscriptions = [];

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

	// ttl state
	ttlState?: string;
	ttlTime?: number;

	// matches?: any;
}

class Controller extends Component<IProps,IState> {
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
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockEndGameEvent(() => {
			this.setState({timerState: 'armed'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: true});
			this.setState({stoppedConfigState: false});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockEndEvent(() => {
			this.setState({timerState: 'ended'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: false});
			this.setState({stoppedConfigState: true});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockStopEvent(() => {
			this.setState({timerState: 'ended'});
			this.setState({mainConfigState: false});
			this.setState({runningConfigState: false});
			this.setState({stoppedConfigState: true});
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

		onScheduleTTLEvent(({time}:{time:number}) => {
			if (time > 30) {
				this.setState({ttlState: 'running'});
			} else if (time < 0) {
				this.setState({ttlState: 'ended'});
			} else if (time < 30) {
				this.setState({ttlState: 'armed'});
			}

			this.setState({ttlTime: time});
			// console.log("Time: " + time);
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

	async componentDidMount() {
		// this.setState({matches: await getMatches()});
		// console.log(this.state.matches);
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

	appendMatchTable(match:any, teams:any) {
		let fll_matches_display:any = document.getElementById("fll_matches_table");

		const team1_number_val = match.next_team1_number;
		var team1_name_val;

		for (const team of teams) {
			if (team.team_number === team1_number_val) {
				team1_name_val = team.team_name;
			}
		}

		const team2_number_val = match.next_team2_number;
		var team2_name_val;

		for (const team of teams) {
			if (team.team_number === team2_number_val) {
				team2_name_val = team.team_name;
			}
		}

		let tr = document.createElement("tr");

		let match_number = document.createElement("td");
		match_number.appendChild(document.createTextNode(match.next_match_number));

		let start_time = document.createElement("td");
		start_time.appendChild(document.createTextNode(match.next_start_time));


		let team1_number = document.createElement("td");
		team1_number.appendChild(document.createTextNode(team1_number_val));

		let team1_name = document.createElement("td");
		team1_name.appendChild(document.createTextNode(team1_name_val));

		let team1_ontable = document.createElement("td");
		team1_ontable.appendChild(document.createTextNode(match.on_table1));
		
		let team2_number = document.createElement("td");
		team2_number.appendChild(document.createTextNode(team2_number_val));

		let team2_name = document.createElement("td");
		team2_name.appendChild(document.createTextNode(team2_name_val));

		let team2_ontable = document.createElement("td");
		team2_ontable.appendChild(document.createTextNode(match.on_table2));

		tr.appendChild(match_number);
		tr.appendChild(start_time);

		tr.appendChild(team1_number);
		tr.appendChild(team1_name);
		tr.appendChild(team1_ontable);

		tr.appendChild(team2_number);
		tr.appendChild(team2_name);
		tr.appendChild(team2_ontable);
		
		if (match.rescheduled) {
			tr.style.backgroundColor = "orange";
		} else if (match.complete) {
			tr.style.backgroundColor = "green";
		}

		fll_matches_display.appendChild(tr);
	}

	clearMatches() {
		let fll_matches_table:any = document.getElementById("fll_matches_table");
		while (fll_matches_table.firstChild) {
			fll_matches_table.removeChild(fll_matches_table.lastChild);
		}
	}

	async displayTeams() {
		const matches = await getMatches();
		const teams = await getTeams();
		this.clearMatches();
		for (const match of matches) {
			this.appendMatchTable(match, teams);
		}
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

		this.displayTeams();
		
		return (
			<div className="row">

				<div className="column-left">
					{/* Timer controls */}
					<div className="timer_controls">

						<h1>Timer Controls</h1>

						{/* Start PreStart */}
						<div className="row">
							<button className="hoverButton green" onClick={this.setStart} disabled={this.state.buttonsDisabled}>Start</button>
							<button className="hoverButton orange" onClick={this.setPrestart} disabled={this.state.buttonsDisabled}>Pre Start</button>
						</div>

						<div className={`clock ${this.state.timerState}`}>
							{ parseTime(this.state.currentTime||0) }
						</div>

						{/* Reload */}
						<div className="row">
							<button className="hoverButton orange" onClick={this.setReload} disabled={this.state.buttonsDisabled}>Reload</button>
						</div>


						{/* Abort */}
						<div className="row">
							<button className="hoverButton red" onClick={this.setStop} disabled={this.state.buttonsDisabled}>Abort</button>
						</div>
					</div>

					{/* Status controls */}
					<div className="status_controls">
						<h1>Status Controls</h1>
						<h3>TTL - Status</h3>
						<div className={`ttl_time ${this.state.ttlState}`}>
							{ parseTTL(this.state.ttlTime||0) }
						</div>
						<div className="row">
							<button className="hoverButton orange" onClick={setPrevMatch} disabled={this.state.buttonsDisabled}>Prev Match</button>
							<button className="hoverButton orange" onClick={setNextMatch} disabled={this.state.buttonsDisabled}>Next Match</button>
						</div>
						<div className="row">
							<button className="hoverButton red" onClick={rescheduleMatch} disabled={this.state.buttonsDisabled}>Reschedule</button>
						</div>
					</div>
				</div>


				{/* Scheduling */}
				<div className="column-right">
					<h1>Schedule Controls</h1>
					
					{/* Round Status Time */}
					<div className="row">
						
					</div>

					{/* Current Match */}
					<div className="row">

					</div>

					{/* All Matches */}
					<div className="matches">
						<table>
							<thead>
								<tr>
									<th>Match Number</th>
									<th>Start Time</th>

									{/* Team 1 */}
									<th>Team1 Number</th>
									<th>Team1 Name</th>
									<th>On Table</th>

									{/* Team 2 */}
									<th>Team2 Number</th>
									<th>Team2 Name</th>
									<th>On Table</th>

								</tr>
							</thead>

							<tbody id="fll_matches_table">
								{/* React controller above */}
							</tbody>
						</table>
					</div>
				</div>


			</div>
		);
	}
}

export default Controller;