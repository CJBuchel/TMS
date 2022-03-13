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
  constructor(props:any) {
    super(props);

    this.state = {
      timerState: 'noState'
    }
  }

  componentDidMount() {
    console.log("Rendered, subscribing to nodes");

    // Start event
    commService.listeners.onClockTimeEvent((time:any) => {
      console.log("Time event: " + time);
      // this.setState({timerState: 'start'});
      // console.log("State: " + this.state.timerState);
    });
  }

  render(): React.ReactNode {
    return(
      <h1>State: {this.state.timerState}</h1>
    );
  }
}

export default Clock