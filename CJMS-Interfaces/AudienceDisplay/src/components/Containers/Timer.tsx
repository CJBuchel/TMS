import { comm_service } from "@cjms_interfaces/shared";
import { Component } from "react";
import Clock from "./Clock";

interface IProps {}

interface IState {
  timerState:string;
  currentTime:number;
}

export default class Timer extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      timerState: "default",
      currentTime: 150
    }

    comm_service.listeners.onClockArmEvent(() => {
      this.setTimerState('armed');
    });

    comm_service.listeners.onClockPrestartEvent(() => {
      this.setTimerState('prerunning');
    });

    comm_service.listeners.onClockStartEvent(() => {
      this.setTimerState('running');
    });

    comm_service.listeners.onClockEndGameEvent(() => {
      this.setTimerState('endgame');
    });

    comm_service.listeners.onClockEndEvent(() => {
      this.setTimerState('ended');
    });

    comm_service.listeners.onClockStopEvent(() => {
      this.setTimerState('ended');
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

  render() {
    return <Clock timerState={this.state.timerState} currentTime={this.state.currentTime}/>;
  }
}