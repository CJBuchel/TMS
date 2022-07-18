import React, { Component } from "react";
import "../../assets/stylesheets/clock.scss";

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

interface IProps {
  timerState?:string;
  currentTime?:number;
}

interface IState {}

class Clock extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];

  constructor(props:any) {
    super(props);
    this.state = {}
  }

  render() {
    return(
      <div className={`clock ${this.props.timerState}`}>
        <div>{ parseTime(this.props.currentTime || 0) }</div>
      </div>
    );
  }
}

export default Clock