import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/application.scss";
import "../../assets/loader.scss";
import { comm_service, IEvent, ITeam } from "@cjms_shared/services";
import { Requests } from "@cjms_interfaces/shared";
import { ITeamScore, initIEvent } from "@cjms_shared/services";

interface IProps {}

interface IState {
  teamData:ITeam[];
  eventData:IEvent;
  rounds:any[];
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: [],
      eventData: initIEvent(),
      rounds: []
    }

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
      this.setData(teamData, eventData);
    });

    comm_service.listeners.onEventUpdate(async () => {
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
      this.setData(teamData, eventData);
    });
  }

  setData(teamData:ITeam[], eventData:IEvent) {
    this.setState({teamData: teamData, eventData: eventData});

    const rounds:any[] = [];
    for (var i = 0; i < eventData.event_rounds; i++) {
      rounds.push(`Round ${i+1}`);
    }

    this.setState({rounds: rounds});
  }

  async componentDidMount() {
    const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
    const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
    this.setData(teamData, eventData);
  }

  tableHeaders() {
    let headers = ['Rank', 'Team'].concat(this.state.rounds);
    return headers;
  }

  tableData() {
    const teamData:ITeam[] = this.state.teamData;
    const tableRowArray:any[] = [];

    for (const team of teamData) {
      let tableRow:any[] = [];
      const teamScores:ITeamScore[] = team.scores;
      const roundScores:any[] = [];

      for (let i = 0; i < this.state.rounds.length; i++) {
        const teamScore = teamScores.filter(scoreObj => scoreObj.scoresheet.round == (i+1));

        if (teamScore.length == 1) {
          roundScores.push(teamScore[0].no_show ? '-' : teamScore[0].score || 0);
        } else if (teamScore.length > 1) {
          roundScores.push('Conflict');
        } else if (teamScore.length <= 0) {
          roundScores.push('');
        } else {
          roundScores.push('Unknown');
        }
      }
      
      tableRow.push(team.ranking, team.team_name);
      tableRow = tableRow.concat(roundScores);
      tableRowArray.push(tableRow);
    }

    return tableRowArray;
  }

  render() {
    if (this.state.teamData && this.state.eventData) {
      return (
        <div id='audience-display-app' className='audience-display-app'>
          <InfiniteTable headers={this.tableHeaders()} data={this.tableData()}/>
        </div>
      );
    } else {
      return (
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      )
    }
  }
}