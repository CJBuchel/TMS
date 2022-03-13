import React, { Component } from "react";
import { comm_service, requests } from "@cjms_interfaces/shared";
import { request_namespaces } from "@cjms_shared/services";
import "../assets/stylesheets/clock.scss";

function pad(number:number, length:number) {
  return (new Array(length + 1).join('0') + number).slice(-length);
}

function parseTime(time:number) {
  if (time <= 30) {
    return `${time | 0}`;
  } else {
    return `${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`;
  }
}

// Game Audio
const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3");
const endAudio = new window.Audio("./sounds/end.mp3");

interface IProps {

}

interface IState {
  soundsEnabled?:boolean;
  buttonsDisabled?:boolean;

  timerState?:string;
  currentTime?:number;
}

class Clock extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];

  constructor(props:any) {
    super(props);
    this.state = {
      timerState: 'noState',
      currentTime: 150
    }

    this.postTimerControl = this.postTimerControl.bind(this);

    this.setPrestart = this.setPrestart.bind(this);
    this.setStart = this.setStart.bind(this);
    this.setStop = this.setStop.bind(this);
    this.setReload = this.setReload.bind(this);
  }
  
  componentDidMount() {
    console.log("Rendered, subscribing to nodes");

    // Prestart event
    comm_service.listeners.onClockPrestartEvent(() => {
      this.setState({timerState: 'prerunning'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Start Event
    comm_service.listeners.onClockStartEvent(() => {
      this.setState({timerState: 'running'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Endgame
    comm_service.listeners.onClockEndGameEvent(() => {
      this.setState({timerState: 'armed'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // End event
    comm_service.listeners.onClockEndEvent(() => {
      this.setState({timerState: 'ended'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Stop event
    comm_service.listeners.onClockStopEvent(() => {
      this.setState({timerState: 'ended'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Reload Event
    comm_service.listeners.onClockReloadEvent(() => {
      this.setState({timerState: 'noState'});
      this.setState({currentTime: 150});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // End Event
    comm_service.listeners.onClockEndEvent(() => {
      this.setState({timerState: 'noState'});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Time event
    comm_service.listeners.onClockTimeEvent((time:number) => {
      this.setState({currentTime: time});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });
  }

  getConfigState() {
    if ((this.state.timerState==='prerunning' || this.state.timerState==='running' || this.state.timerState==='armed') && !this.state.buttonsDisabled) {
      return (
        <div id='running_config' className='timer_controls'>
          <button className="hoverButton red" onClick={this.setStop} disabled={this.state.buttonsDisabled}>Abort</button>
        </div>
      );
    } else if ((this.state.timerState==='ended') && !this.state.buttonsDisabled) {
      return (
        <div id='stopped_config' className='timer_controls'>
          <button className="hoverButton orange" onClick={this.setReload} disabled={this.state.buttonsDisabled}>Reload</button>
        </div>
      );
    } else {
      return (
        <div id='main_config' className='timer_controls'>
          <button className="hoverButton green" onClick={this.setStart} disabled={this.state.buttonsDisabled}>Start</button>
          <button className="hoverButton orange" onClick={this.setPrestart} disabled={this.state.buttonsDisabled}>Pre Start</button>
        </div>
      );
    }
  }

  playsound(audio:HTMLAudioElement) {
    audio.play()
    .catch(err => {
      console.log(err);
    });
  }

  toggleSound(isEnabled:boolean) {
    this.setState({soundsEnabled: isEnabled ? false : true});
  }

  playSoundIfEnabled(audio:HTMLAudioElement) {
    if (this.state.soundsEnabled) {
      this.playsound(audio);
    }
  }

  postTimerControl(e:string) {
    this.setState({buttonsDisabled:true});
    requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, {timerState: e});
    setTimeout(() => this.setState({buttonsDisabled: false}), 2000);
  }

  setPrestart() {this.postTimerControl("prestart");}
  setStart() {this.postTimerControl("start");}
  setStop() {this.postTimerControl("stop");}
  setReload() {this.postTimerControl("reload");}

  render() {
    return(
      <div>
        <div className={`clock ${this.state.timerState}`}>
          <div>{ parseTime(this.state.currentTime || 0) }</div>
        </div>

        { this.getConfigState() }
      </div>
    );
  }
}

export default Clock