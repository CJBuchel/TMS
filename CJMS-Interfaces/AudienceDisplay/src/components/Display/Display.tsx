import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/application.scss";
import "../../assets/loader.scss";
import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";

interface IProps {}

interface IState {
  teamData:any;
  rounds:any[];
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: [],
      rounds: ['Round 1', 'Round 2', 'Round 3']
    }
  }

  setTeamData(data:any) {
    this.setState({teamData: data.data});
  }

  async componentDidMount() {
    const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    this.setTeamData(data);

    comm_service.listeners.onTeamUpdate(async () => {
      const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setTeamData(data);
    });

    comm_service.listeners.onEventUpdate(async () => {
      const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setTeamData(data);
    });
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
        let scoreObject:any[] = teamScores.filter(scoreObj => scoreObj?.roundIndex == i);
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
    if (this.state.teamData) {
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