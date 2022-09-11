import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/application.scss";
import "../../assets/loader.scss";
import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";

interface IProps {}

interface IState {
  teamData:any;
  eventData:any;
  rounds:any[];
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: [],
      eventData: [],
      rounds: []
    }

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      this.setData(teamData, eventData);
    });

    comm_service.listeners.onEventUpdate(async () => {
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      this.setData(teamData, eventData);
    });
  }

  setData(teamData:any, eventData:any) {
    this.setState({teamData: teamData.data, eventData: eventData.data});

    const rounds:any[] = [];
    for (var i = 0; i < eventData.data.event_rounds; i++) {
      rounds.push(`Round ${i+1}`);
    }

    this.setState({rounds: rounds});
  }

  async componentDidMount() {
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    this.setData(teamData, eventData);
  }

  tableHeaders() {
    let headers = ['Rank', 'Team'].concat(this.state.rounds);
    return headers;
  }

  tableData() {
    // console.log(this.state.teamData);
    const teamData = this.state.teamData;
    const tableRowArray:any[] = [];

    for (const team of Object.keys(teamData)) {
      // console.log(teamData[team].team_name);
      let tableRow:any[] = [];
      const teamScores:any[] = teamData[team]?.scores;
      const roundScores:any[] = [];
      
  
      for (let i = 0; i < this.state.rounds.length; i++) {
        let scoreObject:any[] = teamScores.filter(scoreObj => scoreObj?.roundIndex == (i+1));
        if (scoreObject.length == 1) {
          roundScores.push(scoreObject[0]?.score || 0);
        } else if (scoreObject.length > 1) {
          roundScores.push('Conflict');
        } else if (scoreObject.length <= 0) {
          roundScores.push('');
        } else {
          roundScores.push('Unknown');
        }
      }
      
      tableRow.push(teamData[team].ranking, teamData[team].team_name);
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