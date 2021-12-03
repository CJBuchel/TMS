import React, { Component, useState } from "react";
import PropTypes from 'prop-types';
import { onClockEndEvent, onClockEndGameEvent, onClockPrestartEvent, onClockReloadEvent, onClockStartEvent, onClockStopEvent, onClockTimeEvent, onScoreUpdateEvent, onSystemRefreshEvent, sendClockPrestartEvent } from '../comm_service';


// import './Display.css'
import './Table.css'

import { Axios } from 'axios';
import { setInterval } from "timers";

const request = "http://" + window.location.hostname + ":3001/api";
const get_teams_request = request+"/teams/get";

const _removeSubscriptions = [];

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
	existingInfScroll?: boolean;
	disableScroll?: boolean;
	totalHeight?: number;
	targetY?: number;
	currentTime?: number;
	timerHidden?: boolean;
}

class Display extends Component<IProps, IState> {
	constructor(props:any) {
		super(props);

		onClockStartEvent(() => {
			this.setState({timerHidden: false});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockStopEvent(() => {
			this.setState({timerHidden: true});
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onClockEndEvent(() => {
			this.setState({timerHidden: true});
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
			existingInfScroll: false,
			disableScroll: false,
			totalHeight: document.documentElement.scrollHeight,
			targetY: 0,
			currentTime: 150,
			timerHidden: true,
		}

		this.infiniteScroller = this.infiniteScroller.bind(this);
		this.scrollTask = this.scrollTask.bind(this);
		this.createTable = this.createTable.bind(this);
		this.getTeams = this.getTeams.bind(this);
		this.Timer = this.Timer.bind(this);
	}

	componentDidMount() {
		const _removeSubscriptions = [];
		this.setState({disableScroll: false});
		onSystemRefreshEvent(() => {
			this.setState({disableScroll: true});
			window.location.reload();
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});

		onScoreUpdateEvent(() => {
			this.setState({disableScroll: false});
			this.getTeams();
		}).then((removeSubscription:any) => { _removeSubscriptions.push(removeSubscription) })
		.catch((err:any) => {
			console.error(err)
		});
		setTimeout(this.getTeams, 200);
		setTimeout(this.infiniteScroller, 400);
	}

	componentWillUnmount() {
		this.setState({disableScroll: true});
		window.location.reload();
	}

	notNull(value:any) {
		if (value !== null) {
			return value;
		} else {
			return '';
		}
	}

	appendTable(data:any) {
		let fll_display:any = document.getElementById("fll_teams_table");
		var height = 0;
		for (const team of data) {
			let tr = document.createElement("tr");
			tr.setAttribute('id', 'team_row');
			
			
			let td_rank = document.createElement("td");
			td_rank.appendChild(document.createTextNode(this.notNull(team.ranking)));
			
			let td_teamName = document.createElement("td");
			td_teamName.appendChild(document.createTextNode(this.notNull(team.team_name)));
	
			let td_r1 = document.createElement("td");
			td_r1.appendChild(document.createTextNode(this.notNull(team.match_score_1)));
	
			let td_r2 = document.createElement("td");
			td_r2.appendChild(document.createTextNode(this.notNull(team.match_score_2)));
	
			let td_r3 = document.createElement("td");
			td_r3.appendChild(document.createTextNode(this.notNull(team.match_score_3)));
	
			tr.appendChild(td_rank);
			tr.appendChild(td_teamName);
			tr.appendChild(td_r1);
			tr.appendChild(td_r2);
			tr.appendChild(td_r3);
			
			fll_display.appendChild(tr);
			height += tr.offsetHeight;
		}

		// if (!this.state.timerHidden) {
		// 	let timer_display:any = document.getElementById("timer-display");
		// 	height -= timer_display.offsetHeight;
		// }
	
		return height;
	}

	createTable(data:any) {
		var height = 0;
		height += this.appendTable(data);
		height += this.appendTable(data);
		height += this.appendTable(data);
		height += this.appendTable(data);
		height += this.appendTable(data);
		return height;
	}

	async scrollTask() {
		while (true) {
			if (!this.state.disableScroll) {
				for (; (this.state.targetY||0) < (this.state.totalHeight||0); this.setState({targetY: (this.state.targetY||0)+1})) {
					await new Promise(r => setTimeout(r, 40)); // 40 is good speed
					var targetY = (this.state.targetY||0);

					if (document.documentElement.scrollTop < targetY-10 || document.documentElement.scrollTop > targetY+10) { // i'm a genius. lol
						window.scroll({left: 0, top: targetY});
					} else {
						window.scroll({left: 0, top: targetY, behavior: 'smooth'});
					}
				}

				await new Promise(r => setTimeout(r, 100));
				this.setState({targetY: 0});
			} else {
				await new Promise(r => setTimeout(r, 2000));
			}
		}
	}

	infiniteScroller() {
		if (!this.state.existingInfScroll) {
			this.scrollTask();
			this.setState({existingInfScroll: true});
		} else {
			console.log("Something tried to access this one time method twice");
		}
	}

	// 
	// Get team data
	// 
	getTeams() {
		let fll_display:any = document.getElementById("fll_teams_table");

		while (fll_display.firstChild) {
			fll_display.removeChild(fll_display.lastChild);
		}
		
		// Then get create the fetch
		fetch(get_teams_request)
		.then((response) => {
			return response.json();
		}).then(data => {
			this.setState({totalHeight: this.createTable(data)-(this.state.totalHeight || 0)});
		}).catch((error) => {
			console.log(error);
		});
	}

	Timer() {
		return (
			<div className={"timer-display"}>
				{ parseTime(this.state.currentTime||0) }
			</div>
		)
	}

	render() {

		return(
			<div id="fll_display">
				<div id="fll_table_header_wrapper" className="table-wrapper">
					{/* {!this.state.timerHidden && <this.Timer/>} */}
					<table className="fl-table">
						<thead>
							<tr>
								<th>Rank</th>
								<th>TeamName</th>
								<th>Round 1</th>
								<th>Round 2</th>
								<th>Round 3</th>
							</tr>
						</thead>
						<tbody id="fll_teams_table">
							{/* React controller above */}
						</tbody>
					</table>
				</div>
			</div>
		);
	}
}

export default Display;
