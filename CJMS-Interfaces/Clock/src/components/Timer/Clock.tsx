import { Component } from 'react';

import "../../assets/stylesheets/Clock.scss";

interface IProps {
  timerState:string;
  currentTime:number;
}

interface IState {}

export default class Clock extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {}
  }

  pad(value:number, length:number) {
    return (new Array(length + 1).join('0') + value).slice(-length);
  }

  parseTime(time:number) {
    if (time <= 30) {
      return `${time | 0}`;
    } else {
      return `${this.pad(Math.floor(time/60), 2)}:${this.pad(time % 60, 2)}`;
    }
  }

  render() {
    return (
      <div className={`clock ${this.props.timerState}`}>
        <div>{this.parseTime(this.props.currentTime || 0)}</div>
      </div>
    )
  }
}