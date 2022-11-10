import { CJMS_REQUEST_EVENT, CJMS_REQUEST_MATCHES, CJMS_REQUEST_TEAMS, NavMenu, NavMenuContent } from "@cjms_interfaces/shared";
import { comm_service, IEvent, IMatch, initIEvent, ITeam } from "@cjms_shared/services";
import { Component } from "react";
import { TeamDisplay } from "./components/TeamDisplay";

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
      external_teamData: [],
      external_matchData: []
    }

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:IEvent = await CJMS_REQUEST_EVENT(true);
      const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
      const matchData:IMatch[] = await CJMS_REQUEST_MATCHES(true);

      this.setEventData(eventData);
      this.setTeamData(teamData);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:IMatch[] = await CJMS_REQUEST_MATCHES(true);
      this.setMatchData(matchData);
    });
  }

  setEventData(data:IEvent) {
    this.setState({external_eventData:data});
  }

  setTeamData(data:ITeam[]) {
    this.setState({external_teamData:data.sort((a,b) => {return a.ranking-b.ranking})});
  }

  setMatchData(data:IMatch[]) {
    this.setState({external_matchData:data});
  }

  async componentDidMount() {
    const eventData:IEvent = await CJMS_REQUEST_EVENT(true);
    const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
    const matchData:IMatch[] = await CJMS_REQUEST_MATCHES(true);

    this.setEventData(eventData);
    this.setTeamData(teamData);
    this.setMatchData(matchData);
  }

  getNavContents() {
    var navContent:NavMenuContent = {
      navCategories: [
        {
          name: "Team Display",
          links: [
            {
              name: "Teams",
              path: "/",
              linkTo: <TeamDisplay external_eventData={this.state.external_eventData} external_teamData={this.state.external_teamData} external_matchData={this.state.external_matchData}/>
            }
          ]
        }
      ]
    }

    return(navContent);
  }

  render() {
    if (this.state.external_eventData) {
      return (
        <NavMenu navContent={this.getNavContents()}/>
      );
    } else {
      return (
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      );
    }
  }
}