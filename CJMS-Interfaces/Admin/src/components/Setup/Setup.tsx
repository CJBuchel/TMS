import React, {ChangeEvent, Component, InputHTMLAttributes, useState} from "react";
import Papa from "papaparse";

import "../../assets/Setup.scss"
import { CJMS_FETCH_GENERIC_POST, CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { request_namespaces } from "@cjms_shared/services";

interface IProps {}
interface IState {
  csv:any;
  eventName:string;
}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      csv:null,
      eventName:""
    }

    this.updateCSV = this.updateCSV.bind(this);
    this.sendSetup = this.sendSetup.bind(this);
    this.onEventNameChange = this.onEventNameChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.onPurge = this.onPurge.bind(this);
  }

  sendSetup() {
    const submission = {
      csv:this.state.csv,
      eventName:this.state.eventName,
    }

    CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_setup, submission);
    window.location.reload();
  }

  loadMatchTest() {
    CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:true, match:"3"});
    // CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, {timerState: "prestart"});
  }

  loadMatchStop() {
    CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:false, match:""});
    // CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, {timerState: "stop"});
  }

  sendPurge() {
    CJMS_FETCH_GENERIC_GET(request_namespaces.request_post_purge);
  }

  updateCSV(result:any) {
    this.setState({csv:result.data});
    console.log(result.data);
  }

  onEventNameChange(e:ChangeEvent<HTMLInputElement>) {
    e.preventDefault();
    this.setState({eventName:e.target.value});
  }

  onScheduleImport(e:ChangeEvent<HTMLInputElement>) {
    e.preventDefault();
    const f:any = (e.target as HTMLInputElement).files?.[0];
    Papa.parse(f, {header:false, skipEmptyLines:true, complete:this.updateCSV});
  }

  onPurge() {
    if (confirm("Confirm Purge (Can't be undone)") == true) {
      this.sendPurge();
    }
  }

  onSubmit() {
    if (this.state.csv && this.state.eventName) {
      if (confirm("Confirm Submit?") == true) {
        this.sendSetup();
      }
    } else {
      alert("Please input valid data");
    }
  }

  render() {
    return(
      <div className="setup-main">
        <div className="container">

          {/* Main Form */}
          <form onSubmit={(e) => {e.preventDefault()}}>

            {/* Schedule import */}
            <h3>Schedule</h3>
            <input 
              type={"file"} 
              id={"scheduleImport"}
              accept={".csv"}
              onChange={(e) => this.onScheduleImport(e)}
            />
            or - <a href="https://firstaustralia.org/fll-scheduler/">Generate Schedule/CSV</a><br/>

            {/* Main Event Name */}
            <h3>Event Name</h3>
            <input onChange={(e) => this.onEventNameChange(e)} placeholder="event name..."/>

            {/* Controls */}
            <button className="hoverButton back-red" onClick={this.onPurge}>Purge Database</button>
            <button className="hoverButton back-green" onClick={this.onSubmit}>Submit</button>
            <button onClick={this.loadMatchTest}>Load Match Test</button>
            <button onClick={this.loadMatchStop}>Stop Match Test</button>
          </form>

        </div>
      </div>
    );
  }
}