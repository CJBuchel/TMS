import React, { Component } from "react";
import { commService } from "@cjms_interfaces/shared";

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
  }
  
  componentDidMount() {
    console.log("Rendered, subscribing to nodes");
    // Start event
    commService.listeners.onClockTimeEvent((time:number) => {
      this.setState({currentTime: time});
    }).then((removeSubscription:any) => {
      this._removeSubscriptions.push(removeSubscription);
    }).catch((err:any) => {
      console.error(err);
    });
  }

  setPrestart() {}
  setStart() {}
  setStop() {}
  setReload() {}

  render(): React.ReactNode {
    return(
      <h1>State: {this.state.timerState}</h1>
    );
  }
}

export default Clock