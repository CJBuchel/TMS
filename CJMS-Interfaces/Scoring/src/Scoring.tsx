import { Component } from "react";

import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";

import { NavMenu, NavMenuContent } from '@cjms_interfaces/shared';
import { ManualScoring } from './components/ManualScoring';
import { Challenge } from "./components/Challenges";

import "./assets/ScoringApp.scss";

interface IProps {
  scorer:any;
  table:any;
}

interface IState {
  eventData:any;
  teamData:any;
  matchData:any;
  loaded_match:any;
}

export default class Scoring extends Component<IProps,IState> {

  constructor(props:any) {
    super(props);

    this.state = {
      eventData: undefined,
      teamData: undefined,
      matchData: undefined,
      loaded_match: []
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setEventData(eventData, teamData, matchData);
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setEventData(eventData, teamData, matchData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setEventData(eventData, teamData, matchData);
    });

    // comm_service.listeners.onMatchLoaded(async (match:string) => {
    //   this.setLoadedMatch(match);
    // });
  }

  // setLoadedMatch(match:string) {
  //   console.log(match);
  //   const match_loaded = this.state.table_matches.find(e => e.match_number == match);
  //   const loaded_team_number = match_loaded?.on_table1.table == this.props.table ? match_loaded?.on_table1.team_number : match_loaded?.on_table2.team_number;
  //   const team_loaded = this.props.teamData.find(e => e.team_number == loaded_team_number);

  //   console.log(match_loaded);
  //   console.log(team_loaded);

  //   if (team_loaded != undefined || team_loaded != null) {
  //     // this.setState({
  //     //   loaded_team: {value: team_loaded.team_number, label: team_loaded.team_name},
  //     //   loaded_match: match_loaded.match_number
  //     // });
  //     this.setState({loaded_team: {value: team_loaded.team_number, label: team_loaded.team_name}});
  //     this.setState({loaded_match: match_loaded.match_number});
  //   }

  // }

  setEventData(eventData:any, teamData:any, matchData:any) {
    this.setState({eventData: eventData.data, teamData: teamData.data, matchData: matchData.data});
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
    this.setEventData(eventData, teamData, matchData);
  }

  getNavContents() {
    var navContent:NavMenuContent = {
      navCategories: [
        {
          name: "Scoring",
          links: [
            {
              name: "Challenge Scoring",
              path: "/",
              linkTo:<Challenge 
                scorer={this.props.scorer} 
                table={this.props.table}
                match_data={{table_matches:[], loaded_team:{value: '', label: ''}, loaded_match:0}}
                event_data={{eventData:0,teamData:[],matchData:[]}}
              />
            },
    
            {
              name: "Manual Scoring",
              path: "/ManualScoring",
              linkTo:<ManualScoring scorer={this.props.scorer} table={this.props.table} eventData={this.state.eventData} teamData={this.state.teamData}/>
            }
          ]
        },
    
        {
          name: "Matches",
          links: [
            {
              name: `Table [${this.props.table}] Matches`,
              path: "/CurrentTableMatches",
              linkTo:<ManualScoring scorer={this.props.scorer} table={this.props.table} eventData={this.state.eventData} teamData={this.state.teamData}/>
            },
  
            {
              name: "All Matches",
              path: "/AllMatches",
              linkTo:<ManualScoring scorer={this.props.scorer} table={this.props.table} eventData={this.state.eventData} teamData={this.state.teamData}/>
            }
          ]
        }
      ]
    }

    return navContent;
  }

  render() {
    if (!this.state.eventData || !this.state.teamData || !this.state.matchData) {
      return(
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      );
    } else {
      return(
        <div className="scoring-app">
          <NavMenu navContent={this.getNavContents()}/>
        </div>
      )
    }
  }
}