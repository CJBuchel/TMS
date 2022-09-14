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
  external_eventData:any;
  external_teamData:any[];
  external_matchData:any[];

  match_locked:boolean;

  table_matches:any[]; // list of matches for this table
  loaded_match:any;
  loaded_team:any;
}

export default class Scoring extends Component<IProps,IState> {

  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: undefined,
      external_teamData: [],
      external_matchData: [],

      match_locked:true,

      table_matches: [],
      loaded_match: undefined,
      loaded_team: undefined
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);

      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
      this.processData();
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onMatchLoaded((match:string) => {
      this.setLoadedMatch(match);
    });
  }

  setEventData(eventData:any) {
    this.setState({external_eventData: eventData.data, match_locked: eventData.data?.match_locked});
  }

  setTeamData(teamData:any) {
    this.setState({external_teamData: teamData.data});
  }

  setMatchData(matchData:any) {
    this.setState({external_matchData: matchData.data});
  }

  processData() {
    // if (this.state.external_matchData == null || this.state.external_teamData == null) return;
    const teamData = this.state.external_teamData;
    const matchData = this.state.external_matchData;
    // Sort data then set the states

    if (matchData == null) {
      console.log("Data null, returning");
      return;
    }

    teamData.sort(function(a:any,b:any) { return a.team_number-b.team_number});
    matchData.sort(function(a:any,b:any) { return a.match_number-b.match_number});


    const table_matches:any[] = [];
    for (const match of matchData) {
      if (match.on_table1.table == this.props.table || match.on_table2.table == this.props.table) {
        table_matches.push(match);
      }
    }
    
    this.setState({table_matches: table_matches});
    
    // Set the default loaded match to the next one in the (this table) list (test this theory, because it might bug itself every time a score is updated)
    for (const match of table_matches) {
      if (!match.complete) {
        this.setLoadedMatch(match.match_number);
        break;
      }
    }
  }

  // Set loaded match based string (match num)
  setLoadedMatch(match:string) {
    const match_loaded = this.state.table_matches.find(e => e.match_number == match);
    const loaded_team_number = match_loaded?.on_table1.table == this.props.table ? match_loaded?.on_table1.team_number : match_loaded?.on_table2.team_number;
    const team_loaded = this.state.external_teamData.find(e => e.team_number == loaded_team_number);

    console.log(match);
    console.log(this.state.table_matches);
    console.log(team_loaded);

    if (team_loaded != undefined && match_loaded != undefined) {
      this.setState({
        loaded_match: match_loaded,
        loaded_team: team_loaded
      });
    }
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
    this.setEventData(eventData);
    this.setTeamData(teamData);
    this.setMatchData(matchData);
    this.processData();
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
                match_data={{
                  table_matches:this.state.table_matches,
                  loaded_team:this.state.loaded_team,
                  loaded_match:this.state.loaded_match,
                  match_locked:this.state.match_locked
                }}
                event_data={{
                  eventData:this.state.external_eventData,
                  teamData:this.state.external_teamData,
                  matchData:this.state.external_matchData
                }}
              />
            },
    
            {
              name: "Manual Scoring",
              path: "/ManualScoring",
              linkTo:<ManualScoring 
                scorer={this.props.scorer} 
                table={this.props.table} 
                eventData={this.state.external_eventData} 
                teamData={this.state.external_teamData}
              />
            }
          ]
        },
    
        {
          name: "Matches",
          links: [
            {
              name: `Table [${this.props.table}] Matches`,
              path: "/CurrentTableMatches",
              linkTo:<ManualScoring 
                scorer={this.props.scorer} 
                table={this.props.table} 
                eventData={this.state.external_eventData} 
                teamData={this.state.external_teamData}
              />
            },
  
            {
              name: "All Matches",
              path: "/AllMatches",
              linkTo:<ManualScoring 
                scorer={this.props.scorer} 
                table={this.props.table} 
                eventData={this.state.external_eventData} 
                teamData={this.state.external_teamData}
              />
            }
          ]
        }
      ]
    }

    return navContent;
  }

  checkData():boolean {
    return (this.state.external_eventData &&
      this.state.external_matchData &&
      this.state.external_teamData &&
      this.state.loaded_match &&
      this.state.loaded_team &&
      this.state.table_matches.length > 0
    );
  }

  render() {
    if (this.checkData()) {
      return(
        <div className="scoring-app">
          <NavMenu navContent={this.getNavContents()}/>
        </div>
      );
    } else {
      return(
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      )
    }
  }
}