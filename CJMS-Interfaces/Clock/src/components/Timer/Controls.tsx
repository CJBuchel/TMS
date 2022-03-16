import React, { Component } from "react";
import { comm_service, requests } from "@cjms_interfaces/shared";
import { request_namespaces } from "@cjms_shared/services";
interface IProps {
  timerState?:string;
}

interface IState {
  buttonsDisabled?:boolean;
}

// Main Control system for clock states (sender/receiver)
export default class ClockControls extends Component<IProps, IState> {
  _removeSubscriptions:any[] = [];

  constructor(props:any) {
    super(props);
    this.state = {
      buttonsDisabled: false
    }

    this.postTimerControl = this.postTimerControl.bind(this);

    this.setArm = this.setArm.bind(this);
    this.setPrestart = this.setPrestart.bind(this);
    this.setStart = this.setStart.bind(this);
    this.setStop = this.setStop.bind(this);
    this.setReload = this.setReload.bind(this);
  }

  postTimerControl(e:string) {
    this.setState({buttonsDisabled: true});
    requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, {timerState: e});
    setTimeout(() => this.setState({buttonsDisabled: false}), 1000);
  }

  setArm() { this.postTimerControl("arm"); }
  setPrestart() { this.postTimerControl("prestart"); }
  setStart() { this.postTimerControl("start"); }
  setStop() { this.postTimerControl("stop"); }
  setReload() { this.postTimerControl("reload"); }

  renderArmed() {
    if (this.props.timerState === 'armed') {
      return (
        <div>
          <div className="armedModal">
            <h1>MATCH ARMED</h1>
            <div className="controlButtons">
              <button className="hoverButton back-orange" onClick={this.setPrestart}>PRESTART</button>
              <button className="hoverButton back-green" onClick={this.setStart}>START</button>
              <button className="hoverButton back-red" onClick={this.setReload}>CANCEL</button>
            </div>
          </div>
          <div className="armedModalBackdrop">
        </div>
        </div>
      );
    }
  }

  renderControls() {
    if (this.props.timerState === 'default' || this.props.timerState === 'armed') {
      return (
        <div className="timer_controls">
          <button className="hoverButton back-orange" onClick={this.setArm}>{this.props.timerState === 'armed' ? "ARMED" : "ARM"}</button>
        </div>
      );
    } else if (this.props.timerState === 'ended') {
      return (
        <div className="timer_controls">
          <button className="hoverButton back-orange" onClick={this.setReload}>RELOAD</button>
        </div>
      );
    } else {
      return (
        <div className="timer_controls">
          <button className="hoverButton back-red" onClick={this.setStop}>ABORT</button>
        </div>
      );
    }
  }

  render() {
    return (
      <div>
        { this.renderArmed() }
        { this.renderControls() }
      </div>
    );
  }
}