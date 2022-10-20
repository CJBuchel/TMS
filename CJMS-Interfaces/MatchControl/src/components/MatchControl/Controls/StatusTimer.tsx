import { IMatch } from "@cjms_shared/services";
import { Component, ErrorInfo } from "react";

interface IProps {
  external_matchData:IMatch[];
}

interface IState {
  next_match?:IMatch;
  loop?:any;
  rawTTL:number;
  ttlTime:string;
}

export default class StatusTimer extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      next_match:undefined,
      rawTTL:0,
      ttlTime: "00:00:00",
    }

    this.timerLoop = this.timerLoop.bind(this);
  }

  componentDidMount() {
    this.setNextMatch();
    this.startLoop();
  }

  componentWillUnmount(): void {
    clearInterval(this.state.loop);
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (prevProps != this.props) {
      this.setNextMatch();
    }
  }

  setNextMatch() {
    if (this.props.external_matchData.length > 0) {
      const next_match = this.props.external_matchData.find(e => !e.complete && !e.deferred);
      this.setState({next_match: next_match});
    }
  }

  startLoop() {
    this.setState({loop: setInterval(this.timerLoop, 1000)});
  }

  pad(value:number, length:number) {
    return (new Array(length + 1).join('0') + value).slice(-length);
  }

  parseTTL(time:number) {
    var sign = '+';
    if (time < 0) {
      sign = '-';
      time = -time;
    }

    var hours = Math.floor((time)/3600);
    var minutes = Math.floor((time - (hours * 3600)) / 60);
    var seconds = time - (hours * 3600) - (minutes * 60);

    return `${sign}${this.pad(hours, 2)}:${this.pad(minutes, 2)}:${this.pad(seconds, 2)}`
  }

  getCurrentTime() {
    var ttl = 0;
    if (this.state.next_match) {
      var now = new Date();
      var next_time_string:string = (this.state.next_match.start_time).slice(0,8);
      var now_time_string = now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds();
  
      const [hours_next_s, minutes_next_s, seconds_next_s] = next_time_string.split(":");
      const [hours_now_s, minutes_now_s, seconds_now_s] = now_time_string.split(":");
  
      var now_time = (+hours_now_s) * 60 * 60 + (+minutes_now_s) * 60 + (+seconds_now_s);
      var next_match_time = (+hours_next_s) * 60 * 60 + (+minutes_next_s) * 60 + (+seconds_next_s);
      ttl = (next_match_time-now_time);
    }

    return ttl;
  }

  getTTL() {
    this.setState({rawTTL: this.getCurrentTime()});
    this.setState({ttlTime: this.parseTTL(this.getCurrentTime())});
  }

  timerLoop() {
    this.getTTL();
  }

  render() {
    return(
      <span style={{color: `${this.state.rawTTL < 0 ? 'red' : 'green'}`}}>
        {this.state.ttlTime}
      </span>
    );
  }
}