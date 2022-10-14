import { Requests } from "@cjms_interfaces/shared";
import { comm_service, IEvent, IMatch, ITeam, request_namespaces } from "@cjms_shared/services";
import { Component } from "react";
import "./assets/stylesheets/application.scss";
import "./assets/stylesheets/loader.scss";
import "./assets/stylesheets/Display.scss";
import { Timer } from "./components/Timer";
import { initIEvent } from "@cjms_shared/services/lib/components/InterfaceModels/Event";

interface IProps {}

interface IState {
  external_eventData:IEvent;
  external_teamData:ITeam[];
  external_matchData:IMatch[];

  loaded_match?:IMatch;
  team1?:ITeam;
  team2?:ITeam;

  blink_toggle:boolean;
  loop?:any;
}

export default class Display extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];
  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: initIEvent(),
      external_matchData: [],
      external_teamData: [],

      loaded_match: undefined,
      team1: undefined,
      team2: undefined,

      blink_toggle:true
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
      const teamData:any = await Requests.CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setTeamData(teamData);
    });

    comm_service.listeners.onMatchUpdate(async () => {
      const matchData:any = await Requests.CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, true);
      this.setMatchData(matchData);
    });

    comm_service.listeners.onMatchLoaded(async (match:string) => {
      this.setLoadedMatch(match);
    });

    this.blink = this.blink.bind(this);
  }

  blink() {
    if (this.state.blink_toggle) {
      this.setState({blink_toggle: false});
    } else {
      this.setState({blink_toggle: true});
    }
  }

  setEventData(data:IEvent) {
    this.setState({external_eventData:data});
  }

  setTeamData(data:ITeam[]) {
    this.setState({external_teamData:data});
  }

  setMatchData(data:IMatch[]) {
    this.setState({external_matchData:data});
  }

  setLoadedMatch(match:string) {
    if (this.state.external_matchData) {
      const match_loaded = this.state.external_matchData.find(e => e.match_number == match);

      if (match_loaded != undefined && match_loaded != null) {
        this.setState({
          loaded_match: match_loaded,
          team1: this.state.external_teamData.find(e => e.team_number == match_loaded.on_table1.team_number),
          team2: this.state.external_teamData.find(e => e.team_number == match_loaded.on_table2.team_number),
        });
      } else {
        this.setState({
          loaded_match: undefined,
          team1: undefined,
          team2: undefined
        });
      }
    }
  }

  async componentDidMount() {
    const eventData:IEvent = await Requests.CJMS_REQUEST_EVENT(true);
    const teamData:ITeam[] = await Requests.CJMS_REQUEST_TEAMS(true);
    const matchData:IMatch[] = await Requests.CJMS_REQUEST_MATCHES(true);

    this.setEventData(eventData);
    this.setTeamData(teamData);
    this.setMatchData(matchData);

    this.startLoop();
  }

  componentWillUnmount() {
    clearInterval(this.state.loop);
  }

  startLoop() {
    this.setState({loop: setInterval(this.blink, 1000)});
  }

  getMode() {
    var mode:any;
    if (this.state.external_eventData.match_locked) {
      mode = <span style={{color: "red"}}>Match Locked</span>
    } else {
      mode = <span style={{color: "dodgerblue"}}>Match Free</span>
    }

    return <span>{this.state.external_eventData.event_name} | Mode: {mode}</span>
  }

  getMatch() {
    var match:any;
    if (this.state.loaded_match) {
      match = <span style={{color: "green"}}>Match Loaded</span>
    } else {
      match = <span style={{color: "red", opacity: this.state.blink_toggle ? 1 : 0.3}}>No Match Loaded</span>
    }

    return match;
  }

  getMatchNumber() {
    if (this.state.loaded_match) {
      return <span style={{color: "green"}}>#{this.state.loaded_match.match_number}</span>
    }
  }

  getContent() {
    return(
      <div className="Display-Timer">

        <div className="Display-Timer-Top">
          <h1>Status: {this.getMatch()}</h1>
        </div>

        <div className="Display-Timer-Middle">
          <Timer/>
        </div>

        <div className="Display-Timer-Bottom">
          
          <div className="column-left-team">
            <h1>
              {/* On Table: <span style={{color: `${this.state.loaded_match?.on_table1?.table}`}}>{this.state.loaded_match?.on_table1?.table}</span> */}
              On Table: <span>{this.state.loaded_match?.on_table1.table}</span>
            </h1>
            <h1 style={{color: "green"}}>{this.state.team1?.team_number} | {this.state.team1?.team_name}</h1>
          </div>

          <div className="column-match-number">
            <h1>Match</h1>
            <div className="content">
              <h1>{this.getMatchNumber()}</h1>
            </div>
          </div>

          <div className="column-right-team">
            <h1>
              {/* On Table: <span style={{color: `${this.state.loaded_match?.on_table2?.table}`}}>{this.state.loaded_match?.on_table2?.table}</span> */}
              On Table: <span>{this.state.loaded_match?.on_table2.table}</span>
            </h1>
            <h1 style={{color: "green"}}>{this.state.team2?.team_number} | {this.state.team2?.team_name}</h1>
          </div>
        </div>
      </div>
    );
  }

  render() {
    if (this.state.external_eventData) {
      return this.getContent();
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