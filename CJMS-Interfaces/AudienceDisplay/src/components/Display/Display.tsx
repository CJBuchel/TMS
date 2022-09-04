import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/application.scss";
import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";

interface IProps {}

interface IState {
  teamData:any;
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: []
    }
  }

  async componentDidMount() {
    const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    this.setState({teamData: data.data});

    comm_service.listeners.onTeamUpdate(async () => {
      const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setState({teamData: data.data});
    });
  }

  tableHeaders() {
    let headers = ['Rank', 'Team', 'Round 1', 'Round 2', 'Round 3'];
    return headers;
  }

  tableData() {
    console.log(this.state.teamData);
    const teamData = this.state.teamData;
    const tableRowArray:any[] = [];

    for (const team of Object.keys(teamData)) {
      // console.log(teamData[team].team_name);
      tableRowArray.push({
        Rank: teamData[team].ranking,
        Team: teamData[team].team_name,
        Round1: teamData[team]?.scores[0]?.score || '',
        Round2: teamData[team]?.scores[1]?.score || '',
        Round3: teamData[team]?.scores[2]?.score || ''
      });
    }

    return tableRowArray;
  }

  render() {
    if (this.state.teamData) {
      // this.tableData();
      return (
        <div id='audience-display-app' className='audience-display-app'>
          <InfiniteTable headers={this.tableHeaders()} data={this.tableData()}/>
        </div>
      );
    } else {
      return (
        <h2>Waiting For Team Data</h2>
      )
    }
  }
}