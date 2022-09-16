import { comm_service, NavMenu, NavMenuContent } from "@cjms_interfaces/shared";
import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { request_namespaces } from "@cjms_shared/services";
import { Component } from "react";

import "./assets/stylesheets/loader.scss";
import { MatchControl } from "./components/MatchControl";

interface IProps {}

interface IState {
  external_eventData:any;
  external_teamData:any[];
  external_matchData:any[];
}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: undefined,
      external_matchData: [],
      external_teamData: [],
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);

      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setMatchData(matchData);
    });
  }

  setEventData(data:any) {
    this.setState({external_eventData:data.data});
  }

  setTeamData(data:any) {
    this.setState({external_teamData:data.data});
  }

  setMatchData(data:any) {
    this.setState({external_matchData:data.data});
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
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
              linkTo:<MatchControl external_matchData={this.state.external_matchData} external_teamData={this.state.external_teamData}/>
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