import { CJMS_POST_MATCH_UPDATE, comm_service } from "@cjms_interfaces/shared";
import { Requests } from "@cjms_interfaces/shared";
import { IEvent, IMatch, initIEvent, initIMatch, initITeam, ITeam, request_namespaces } from "@cjms_shared/services";
import { Component } from "react";

import "../../../assets/stylesheets/Controls.scss";
import MatchTimer from "./MatchTimer";
import StatusTimer from "./StatusTimer";

interface IProps {
  external_eventData:IEvent;
  external_matchData:IMatch[];
  external_teamData:ITeam[];
  selected_match?:IMatch;
}

interface IState {
  loaded_match?:IMatch;
  blink_toggle:boolean;
  loop?:any;

  timerState:string;
  currentTime:number;
  soundsEnabled:boolean;
}

const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3"); // @intercom sound down
const endAudio = new window.Audio("./sounds/end.mp3");

export default class Controls extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      loaded_match: undefined,
      blink_toggle: true,

      timerState: "default",
      currentTime: 150,
      soundsEnabled: true
    }

    comm_service.listeners.onMatchLoaded(async (match:string) => {
      this.setLoadedMatch(match);
    });

    comm_service.listeners.onClockArmEvent(() => {
      this.setTimerState('armed');
    });

    comm_service.listeners.onClockPrestartEvent(() => {
      this.setTimerState('prerunning');
    });

    comm_service.listeners.onClockStartEvent(() => {
      this.setTimerState('running');
      this.playSoundIfEnabled(startAudio);
    });

    comm_service.listeners.onClockEndGameEvent(() => {
      this.setTimerState('endgame');
      endGameAudio.volume = 0.5;
      this.playSoundIfEnabled(endGameAudio);
    });

    comm_service.listeners.onClockEndEvent(() => {
      this.setTimerState('ended');
      this.playSoundIfEnabled(endAudio);
    });

    comm_service.listeners.onClockStopEvent(() => {
      this.setTimerState('ended');
      this.playSoundIfEnabled(stopAudio)
    });

    comm_service.listeners.onClockReloadEvent(() => {
      this.setTimerState('default');
      this.setCurrentTime(150);
    });

    comm_service.listeners.onClockTimeEvent((time:number) => {
      this.setCurrentTime(time);
    });

    this.blink = this.blink.bind(this);
  }

  setCurrentTime(time:number) {
    this.setState({currentTime:time});
  }

  setTimerState(state:string) {
    this.setState({timerState: state});
  }

  playSound(audio:HTMLAudioElement) {
    audio.play().catch(err => {
      console.log(err);
    });
  }

  enableSounds(enable:boolean) {
    this.setState({soundsEnabled: enable});
  }

  playSoundIfEnabled(audio:HTMLAudioElement) {
    if (this.state.soundsEnabled) {
      this.playSound(audio);
    }
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
    if (this.props.external_matchData.length > 0) {
      const match_loaded = this.props.external_matchData.find(e => e.match_number == match);
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
      const team:ITeam = this.props.external_teamData.find(e => e.team_number == this.props.selected_match?.on_table1?.team_number) || initITeam();
      return <span>{this.props.selected_match?.on_table1?.table}: <span style={{color: "green"}}>{this.props.selected_match?.on_table1?.team_number} | {team?.team_name}</span></span>
    }
  }

  getOnTable2() {
    if (this.props.selected_match && this.props.external_teamData) {
      const team:ITeam = this.props.external_teamData.find(e => e.team_number == this.props.selected_match?.on_table2?.team_number) || initITeam();
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

  getStatusMatch() {
    if (this.state.loaded_match) {
      return <span style={{color: "green"}}>Match Loaded</span>
    } else {
      return this.getLoadedMatch();
    }
  }

  getLoadedTable1() {
    if (this.state?.loaded_match) {
      const team:ITeam = this.props.external_teamData.find(e => e.team_number == this.state?.loaded_match?.on_table1?.team_number) || initITeam();
      const table = this.state?.loaded_match?.on_table1?.table;
      return (
        <span style={{color: "orange"}}>
          {table}: 
          <span>
            {team?.team_number} | {team?.team_name}
          </span>
        </span>
      )
    }
  }

  getLoadedTable2() {
    if (this.state?.loaded_match) {
      const team:ITeam = this.props.external_teamData.find(e => e.team_number == this.state?.loaded_match?.on_table2?.team_number) || initITeam();
      const table = this.state?.loaded_match?.on_table2?.table;
      return (
        <span style={{color: "orange"}}>
          {table}: 
          <span>
            {team?.team_number} | {team?.team_name}
          </span>
        </span>
      )
    }
  }

  handleDeferMatch(defer:boolean) {
    console.log("Defer match");
    if (this.props.selected_match) {
      var match_update = this.props.selected_match;
      match_update.deferred = defer;
      CJMS_POST_MATCH_UPDATE(match_update.match_number, match_update);
      comm_service.senders.sendEventUpdateEvent(true);
    }
  }

  handleLoadMatch() {
    if (this.props.selected_match != undefined) {
      Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:true, match: this.props.selected_match?.match_number});
    }
  }

  handleUnloadMatch() {
    Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:false, match:""});
  }

  handleSetMatchComplete(complete:boolean) {
    if (this.state.loaded_match != undefined) {
      Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_complete, {complete:complete, match:this.state.loaded_match?.match_number});
      if (complete) {
        this.handleUnloadMatch();
      }
    }
  }

  handlePreStartMatch() {
    Requests.CJMS_POST_TIMER("prestart");
  }

  handleStartMatch() {
    Requests.CJMS_POST_TIMER("start");
  }

  handleAbortMatch() {
    Requests.CJMS_POST_TIMER("stop");
  }

  handleReloadMatch() {
    Requests.CJMS_POST_TIMER("reload");
    this.setState({timerState: "default"});
    this.setCurrentTime(150);
  }

  getTimerControls() {
    if (this.state.timerState == "default" || this.state.timerState == "armed") {
      return (
        <div className="buttons">
          {/* Prestart */}
          <button 
            onClick={() => this.handlePreStartMatch()}
            className={`hoverButton ${(this.state.loaded_match && !this.state.loaded_match?.complete) || !this.props.external_eventData?.match_locked ? "back-orange" : "back-half-transparent"} buttons`}
            disabled={(!this.state.loaded_match || this.state.loaded_match?.complete) && this.props.external_eventData?.match_locked}
          >Pre Start</button>

          {/* Start */}
          <button 
            onClick={() => this.handleStartMatch()}
            className={`hoverButton ${(this.state.loaded_match && !this.state.loaded_match?.complete) || !this.props.external_eventData?.match_locked ? "back-green" : "back-half-transparent"} buttons`}
            disabled={(!this.state.loaded_match || this.state.loaded_match?.complete) && this.props.external_eventData?.match_locked}
          >Start</button>
        </div>
      );
    } else if (this.state.timerState == 'ended') {
      return (
        <div className="singular">
          {/* Reload */}
          <button 
            onClick={() => this.handleReloadMatch()}
            className={`hoverButton back-orange`}
          >Reload</button>
        </div>
      );
    } else {
      return (
        <div className="singular">
          {/* Abort */}
          <button
            onClick={() => this.handleAbortMatch()}
            className={"hoverButton back-red"}
            // disabled={!this.state.loaded_match}
          >Abort</button>
        </div>
      )
    }
  }

  getMatchContent() {
    const select_name:string = this.state.loaded_match ? "Loaded" : "Selected";
    return(
      <>
        <h1>{select_name} [ {this.state.loaded_match ? this.getLoadedMatch() : this.getMatchNumber()} ]</h1>
        <h2>On Table {this.state.loaded_match ? this.getLoadedTable1() : this.getOnTable1()}</h2>
        <h2>On Table {this.state.loaded_match ? this.getLoadedTable2() : this.getOnTable2()}</h2>
        <div className="buttons">
          <button 
            onClick={() => this.handleLoadMatch()}
            className={`hoverButton ${(!this.state.loaded_match) ? "back-orange" : "back-half-transparent"} buttons`}
            disabled={(this.state.loaded_match != undefined)}
          >Load</button>

          <button 
            onClick={() => this.handleUnloadMatch()}
            className={`hoverButton ${(this.state.loaded_match && (this.state.timerState == 'default' || this.state.timerState == 'armed' || this.state.timerState == 'ended')) ? "back-orange" : "back-half-transparent"} buttons`}
            disabled={(!this.state.loaded_match || (this.state.timerState != 'default' && this.state.timerState != 'armed' && this.state.timerState != 'ended'))}
          >Unload</button>
        </div>

        <div className="buttons">
        </div>
      </>
    );
  }

  render() {
    return(
      <div className="controls">
        <div className="match_info">
          {this.getMatchContent()}
        </div>

        <div className="status_clock">
          TTL: <span className="clock"><StatusTimer external_matchData={this.props.external_matchData}/></span>
        </div>

        <div className="loaded_info">
          <h1>Status: {this.getStatusMatch()}</h1>
          <div className="buttons">

            {/* Unload Match */}
            <button 
              onClick={() => this.handleSetMatchComplete(false)}
              className={`hoverButton ${this.state.loaded_match ? "back-red" : "back-half-transparent"} buttons`}
              disabled={!this.state.loaded_match}
            >Set Incomplete</button>

            {/* Set match as complete */}
            <button 
              onClick={() => this.handleSetMatchComplete(true)}
              className={`hoverButton ${this.state.loaded_match ? "back-green" : "back-half-transparent"} buttons`}
              disabled={!this.state.loaded_match}
            >Set Complete</button>
          </div>

          <div className="defer_button">
            <button 
              onClick={() => this.handleDeferMatch(!this.props.selected_match?.deferred || false)}
              className={`hoverButton ${(!this.state.loaded_match && this.props.selected_match != undefined) ? "back-cyan" : "back-half-transparent"} buttons`}
              disabled={(this.state.loaded_match != undefined)}
            >{this.props.selected_match?.deferred ? "Schedule" : "Defer"}</button>
          </div>
          
        </div>

        <div className="timer_controls">
          <MatchTimer timerState={this.state.timerState} currentTime={this.state.currentTime}/>
          {this.getTimerControls()}
        </div>

      </div>
    );
  }
}