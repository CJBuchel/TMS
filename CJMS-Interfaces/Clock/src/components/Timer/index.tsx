import { Component, ReactNode } from "react";
import Clock from "./Clock";
import ClockControls from "./Controls";

import { comm_service } from "@cjms_interfaces/shared";

interface IProps {}

interface IState {
  timerState?:string;
  currentTime?:number;
  soundsEnabled?:boolean;
}

const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3");
const endAudio = new window.Audio("./sounds/end.mp3");

export default class Timer extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];
  constructor(props:any) {
    super(props);
    this.state = {
      timerState: "default", // (default, armed, endgame, prerunning, running, ended)
      currentTime: 150,
      soundsEnabled: false,
    }
  }

  playSound(audio:HTMLAudioElement) {
    audio.play().catch(err => {
      console.log(err);
    });
  }

  toggleSounds(isEnabled:boolean) {
    this.setState({soundsEnabled: isEnabled ? false : true});
  }

  playSoundIfEnabled(audio:HTMLAudioElement) {
    if (this.state.soundsEnabled) {
      this.playSound(audio);
    }
  }

  componentDidMount() {
    // Subscribing to event nodes

    comm_service.listeners.onClockArmEvent(() => {
      this.setState({timerState: 'armed'});
    }).then((removeSubsciption:any) => {
      this._removeSubscriptions.push(removeSubsciption);
    }).catch((err:any) => {
      console.error(err);
    });

    // Prestart event
    comm_service.listeners.onClockPrestartEvent(() => {
      this.setState({timerState: 'prerunning'});
    }).then((removeSubsciption:any) => {
      this._removeSubscriptions.push(removeSubsciption);
    }).catch((err:any) => {
      console.error(err);
    });

    // Start Event
    comm_service.listeners.onClockStartEvent(() => {
      this.setState({timerState: 'running'});
      this.playSoundIfEnabled(startAudio);
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Endgame
    comm_service.listeners.onClockEndGameEvent(() => {
      this.setState({timerState: 'endgame'});
      this.playSoundIfEnabled(endGameAudio);
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // End event
    comm_service.listeners.onClockEndEvent(() => {
      this.setState({timerState: 'ended'});
      this.playSoundIfEnabled(endAudio);
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Stop event
    comm_service.listeners.onClockStopEvent(() => {
      this.setState({timerState: 'ended'});
      this.playSoundIfEnabled(stopAudio);
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // Reload Event
    comm_service.listeners.onClockReloadEvent(() => {
      this.setState({timerState: 'default'});
      window.location.reload();
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });

    // End Event
    comm_service.listeners.onClockEndEvent(() => {
      this.setState({timerState: 'ended'});
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

  render() {
    console.log(this.state.timerState);
    return (
      <div>
        <Clock timerState={this.state.timerState} currentTime={this.state.currentTime}/>
        <ClockControls timerState={this.state.timerState}/>
      </div>
    );
  }
}