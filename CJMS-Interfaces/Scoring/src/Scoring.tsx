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
}

export default class Scoring extends Component<IProps,IState> {

  constructor(props:any) {
    super(props);

    this.state = {
      eventData: undefined,
      teamData: undefined,
      matchData: undefined,
    }
  }

  setEventData(eventData:any, teamData:any, matchData:any) {
    this.setState({eventData: eventData.data, teamData: teamData.data, matchData: matchData.data});
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
    this.setEventData(eventData, teamData, matchData);

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
              linkTo:<Challenge scorer={this.props.scorer} table={this.props.table} eventData={this.state.eventData} teamData={this.state.teamData} matchData={this.state.matchData}/>
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