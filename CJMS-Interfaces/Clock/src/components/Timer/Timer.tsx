import { comm_service } from "@cjms_interfaces/shared";
import { Component } from "react";
import Clock from "./Clock";

interface IProps {}

interface IState {
  timerState:string;
  currentTime:number;
  soundsEnabled:boolean;
}

const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3");
const endAudio = new window.Audio("./sounds/end.mp3");

export default class Timer extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      timerState: "default",
      currentTime: 150,
      soundsEnabled: true
    }

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

  render() {
    return <Clock timerState={this.state.timerState} currentTime={this.state.currentTime}/>;
  }
}