import { Component, ReactNode } from "react";
import Clock from "./Clock";
import ClockControls from "./Controls";

import { comm_service } from "@cjms_interfaces/shared";

interface IProps {}

interface IState {
  timerState?:string;
  currentTime?:number;
}

export default class Timer extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];
  constructor(props:any) {
    super(props);
    this.state = {
      timerState: "default", // (default, armed, prerunning, running, ended)
      currentTime: 150
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

  render() {
    return (
      <div>
        <Clock timerState={this.state.timerState} currentTime={this.state.currentTime}/>
      </div>
    );
  }
}