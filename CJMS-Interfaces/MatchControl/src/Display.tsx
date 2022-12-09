import { comm_service, NavMenu, NavMenuContent, Requests } from "@cjms_interfaces/shared";

import { IEvent, IMatch, initIEvent, ITeam } from "@cjms_shared/services";
import { Component } from "react";

import "./assets/stylesheets/loader.scss";
import { MatchControl } from "./components/MatchControl";
import { MatchEdit } from "./components/MatchEdit";

interface IProps {}

interface IState {
  external_eventData:IEvent;
  external_teamData:ITeam[];
  external_matchData:IMatch[];
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: initIEvent(),
      external_matchData: [],
      external_teamData: [],
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);

      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);
      this.setMatchData(matchData);
    });
  }

  setEventData(data:IEvent) {
    this.setState({external_eventData:data});
  }

  setTeamData(data:ITeam[]) {
    this.setState({external_teamData:data});
  }

  setMatchData(data:IMatch[]) {
    data.sort(function(a,b) {
      return a.start_time.localeCompare(b.start_time, undefined, {
        numeric: true,
        sensitivity: 'base'
      })
    });
    this.setState({external_matchData:data});
  }

  async componentDidMount() {
    const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
    const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
    const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);

    this.setEventData(eventData);
    this.setTeamData(teamData);
    this.setMatchData(matchData);
  }

  getNavContents() {
    var navContent:NavMenuContent = {
      navCategories: [
        {
          name: "Match Control",
          links: [
            {
              name: "Main Control",
              path: "/",
              linkTo:<MatchControl external_eventData={this.state.external_eventData} external_matchData={this.state.external_matchData} external_teamData={this.state.external_teamData}/>
            },
            {
              name: "Match Edit",
              path: "/MatchEdit",
              linkTo:<MatchEdit external_eventData={this.state.external_eventData} external_teamData={this.state.external_teamData} external_matchData={this.state.external_matchData}/>
            }
          ]
        }
      ]
    }

    return(navContent);
  }

  render() {
    if (this.state.external_eventData) {
      return(
        <NavMenu navContent={this.getNavContents()}/>
      );
    } else {
      return(
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      );
    }
  }
}