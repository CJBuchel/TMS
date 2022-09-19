import { comm_service } from "@cjms_interfaces/shared";
import { CJMS_FETCH_GENERIC_POST } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { request_namespaces } from "@cjms_shared/services";
import { Component } from "react";

import "../../assets/stylesheets/Controls.scss";
import StatusTimer from "./StatusTimer";

interface IProps {
  external_matchData:any[];
  external_teamData:any[];
  selected_match:any;
}

interface IState {
  loaded_match:any;
  blink_toggle:boolean;
  loop?:any;
}

export default class Controls extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      loaded_match: undefined,
      blink_toggle: true
    }

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

  componentDidMount() {
    this.startBlinkLoop();
  }

  componentWillUnmount() {
    clearInterval(this.state.loop);
  }

  startBlinkLoop() {
    this.setState({loop: setInterval(this.blink, 1000)});
  }

  setLoadedMatch(match:string) {
    if (this.props.external_matchData) {
      const match_loaded:any = this.props.external_matchData.find(e => e.match_number == match);
      this.setState({loaded_match: match_loaded});
    }
  }

  getMatchNumber() {
    if (this.props.selected_match) {
      return <span style={{color: "green"}}>#{this.props.selected_match?.match_number}</span>
    }
  }

  getOnTable1() {
    if (this.props.selected_match && this.props.external_teamData) {
      const team = this.props.external_teamData.find(e => e.team_number == this.props.selected_match?.on_table1?.team_number);
      return <span>{this.props.selected_match?.on_table1?.table}: <span style={{color: "green"}}>{this.props.selected_match?.on_table1?.team_number} | {team?.team_name}</span></span>
    }
  }

  getOnTable2() {
    if (this.props.selected_match && this.props.external_teamData) {
      const team = this.props.external_teamData.find(e => e.team_number == this.props.selected_match?.on_table2?.team_number);
      return <span>{this.props.selected_match?.on_table2?.table}: <span style={{color: "green"}}>{this.props.selected_match?.on_table2?.team_number} | {team?.team_name}</span></span>
    }
  }

  getLoadedMatch() {
    var match:any;
    if (this.state.loaded_match) {
      match = <span style={{color: "orange"}}>#{this.state.loaded_match?.match_number}</span>
    } else {
      match = <span style={{color: "red", opacity: this.state.blink_toggle ? 1 : 0.3}}>No Match Loaded</span>
    }

    return match;
  }

  handleLoadMatch() {
    if (this.props.selected_match) {
      CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:true, match: this.props.selected_match?.match_number});
    }
  }

  handleUnloadMatch() {
    CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:false, match:""});
  }

  render() {
    return(
      <div className="controls">
        <div className="match_info">
        <h1>Selected [ {this.getMatchNumber()} ]</h1>
          <h2>On Table {this.getOnTable1()}</h2>
          <h2>On Table {this.getOnTable2()}</h2>
          <button onClick={() => this.handleLoadMatch()} className="hoverButton back-orange">Load Match</button>
        </div>

        <div className="status_clock">
          TTL: <span className="clock"><StatusTimer external_matchData={this.props.external_matchData}/></span>
        </div>

        <div className="loaded_info">
          <h2>Loaded: {this.getLoadedMatch()}</h2>

          <div className="buttons">
            <button onClick={() => this.handleUnloadMatch()} className="hoverButton back-orange buttons">Unload</button>
            <button className="hoverButton back-green buttons">Set Complete</button>
          </div>
        </div>

      </div>
    );
  }
}