import React, { Component } from "react";
import { comm_service } from "@cjms_interfaces/shared";
interface IProps {

}

interface IState {
  soundsEnabled?:boolean;
  buttonsDisabled?:boolean;
  timerState?:string;
}

const startAudio = new window.Audio("./sounds/start.mp3");
const stopAudio = new window.Audio("./sounds/stop.mp3");
const endGameAudio = new window.Audio("./sounds/end-game.mp3");
const endAudio = new window.Audio("./sounds/end.mp3");

// Main Control system for clock states (sender/receiver)
export default class ClockControls extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];

  constructor(props:any) {
    super(props);
    this.state = {

    }
  }

  componentDidMount() {}

  render() {
    return(
      <div>
        
      </div>
    );
  }
}