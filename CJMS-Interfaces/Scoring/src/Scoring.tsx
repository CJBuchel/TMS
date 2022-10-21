import { Component } from "react";

import { Requests } from "@cjms_interfaces/shared";
import { comm_service, IEvent, IMatch, initIEvent, initIMatch, initITeam, ITeam } from "@cjms_shared/services";

import { NavMenu, NavMenuContent } from '@cjms_interfaces/shared';
import { ManualScoring } from './components/ManualScoring';
import { ChallengeScoring } from "./components/ChallengeScoring";

import "./assets/ScoringApp.scss";
import { AllMatches } from "./components/AllMatches";
import { TableMatches } from "./components/TableMatches";

interface IProps {
  scorer:string;
  table:string;
}

interface IState {
  external_eventData:IEvent;
  external_teamData:ITeam[];
  external_matchData:IMatch[];

  match_locked:boolean;

  table_matches:IMatch[]; // list of matches for this table
  loaded_match:IMatch;
  loaded_team:ITeam;
}

export default class Scoring extends Component<IProps,IState> {

  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: initIEvent(),
      external_teamData: [],
      external_matchData: [],

      match_locked: true,

      table_matches: [],
      loaded_match: initIMatch(),
      loaded_team: initITeam()
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);

      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
      this.processData();
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onMatchLoaded((match:string) => {
      this.setLoadedMatch(match);
    });
  }

  setEventData(eventData:IEvent) {
    this.setState({external_eventData: eventData, match_locked: (eventData?.match_locked || false)});
  }

  setTeamData(teamData:ITeam[]) {
    this.setState({external_teamData: teamData});
  }

  setMatchData(matchData:IMatch[]) {
    this.setState({external_matchData: matchData});
  }

  processData() {
    // if (this.state.external_matchData == null || this.state.external_teamData == null) return;
    const teamData:ITeam[] = this.state.external_teamData;
    const matchData:IMatch[] = this.state.external_matchData;
    // Sort data then set the states

    if (matchData == null) {
      console.log("Data null, returning");
      return;
    }

    teamData.sort(function(a:any,b:any) { return a.team_number-b.team_number});
    matchData.sort(function(a:any,b:any) { return a.match_number-b.match_number});


    const table_matches:IMatch[] = matchData.filter((match) => {return match.on_table1.table == this.props.table || match.on_table2.table == this.props.table});
    
    this.setState({table_matches: table_matches});
    
    // Set the default loaded match to the next one in the (this table) list (test this theory, because it might bug itself every time a score is updated)
    var loaded_match:string | undefined = undefined;
    for (const match of table_matches) {
      if (match.on_table1.table === this.props.table && (!match.on_table1.score_submitted && !match.deferred && match.complete)) {
        loaded_match = match.match_number;
        break;
      } else if (match.on_table2.table === this.props.table && (!match.on_table2.score_submitted && !match.deferred && match.complete)) {
        loaded_match = match.match_number;
        break;
      }
    }

    if (loaded_match === undefined) {
      for (const match of table_matches) {
        if (match.on_table1.table === this.props.table && (!match.on_table1.score_submitted && !match.deferred)) {
          loaded_match = match.match_number;
          break;
        } else if (match.on_table2.table === this.props.table && (!match.on_table2.score_submitted && !match.deferred)) {
          loaded_match = match.match_number;
          break;
        }
      }
    }

    if (loaded_match != undefined) {
      this.setLoadedMatch(loaded_match);
    }
  }

  // Set loaded match based string (match num)
  setLoadedMatch(match:string) {
    const match_loaded = this.state.table_matches.find(e => e.match_number == match);
    const loaded_team_number = match_loaded?.on_table1.table == this.props.table ? match_loaded?.on_table1.team_number : match_loaded?.on_table2.team_number;
    const team_loaded = this.state.external_teamData.find(e => e.team_number == loaded_team_number);

    if (team_loaded != undefined && match_loaded != undefined) {
      this.setState({
        loaded_match: match_loaded,
        loaded_team: team_loaded
      });
    }
  }

  async componentDidMount() {
    const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
    const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
    const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);

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
              linkTo:<ChallengeScoring 
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
                matchData={this.state.external_matchData}
              />
            }
          ]
        },
    
        {
          name: "Matches",
          links: [
            {
              name: `Table [${this.props.table}] Matches`,
              path: "/TableMatches",
              linkTo:<TableMatches 
                external_teamData={this.state.external_teamData}
                external_tableMatches={this.state.table_matches}
              />
            },
  
            {
              name: "All Matches",
              path: "/AllMatches",
              linkTo:<AllMatches 
                external_teamData={this.state.external_teamData}
                external_matchData={this.state.external_matchData}
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