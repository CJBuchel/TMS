import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/stylesheets/application.scss";
import "../../assets/stylesheets/loader.scss";
import { comm_service, IEvent, IMatch, initIMatch, ITeam } from "@cjms_shared/services";
import { Requests } from "@cjms_interfaces/shared";
import { ITeamScore, initIEvent } from "@cjms_shared/services";
import InfoFooter from "../Containers/InfoFooter";

interface IProps {}

interface IState {
  eventData?:IEvent;
  teamData:ITeam[];
  matchData:IMatch[];
  rounds:any[];
  loaded_match:IMatch;
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: [],
      matchData: [],
      rounds: [],
      loaded_match: initIMatch()
    }

    comm_service.listeners.onMatchLoaded(async (match_number:string) => {
      if (this.state.matchData.length > 0) {
        this.setState({loaded_match: this.state.matchData.find((match) => match.match_number === match_number) || initIMatch()});
      }
    })

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);
      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
    });
  }

  setEventData(eventData:IEvent) {
    this.setState({eventData: eventData});
    if (eventData) {  
      const rounds:any[] = [];
      for (var i = 0; i < eventData.event_rounds; i++) {
        rounds.push(`Round ${i+1}`);
      }
  
      this.setState({rounds: rounds});
    }
  }

  setTeamData(teamData:ITeam[]) {
    if (teamData) {
      this.setState({teamData: teamData.sort((a,b) => {return a.ranking-b.ranking})});
    }
  }

  setMatchData(matchData:IMatch[]) {
    this.setState({matchData: matchData});
  }

  setData(eventData:IEvent, teamData:ITeam[], matchData:IMatch[]) {
    if (eventData && teamData.length > 0 && matchData.length > 0) {
      this.setState({teamData: teamData.sort((a,b) => {return a.ranking-b.ranking}), eventData: eventData});
      this.setState({matchData: matchData});
  
      const rounds:any[] = [];
      for (var i = 0; i < eventData.event_rounds; i++) {
        rounds.push(`Round ${i+1}`);
      }
  
      this.setState({rounds: rounds});
    }
  }

  async componentDidMount() {
    const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
    const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
    const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);
    this.setData(eventData, teamData, matchData);
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

  matchInfo() {
    if (this.state.loaded_match.match_number.length > 0 && this.state.eventData) {
      return <InfoFooter eventData={this.state.eventData} teamData={this.state.teamData} matchData={this.state.matchData} loaded_match={this.state.loaded_match}/>
    }
  }

  render() {
    if (this.state.eventData && this.state.teamData.length > 0 && this.state.matchData.length > 0) {
      return (
        <div id='audience-display-app' className='audience-display-app'>
          <InfiniteTable headers={this.tableHeaders()} data={this.tableData()}/>
          {this.matchInfo()}
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