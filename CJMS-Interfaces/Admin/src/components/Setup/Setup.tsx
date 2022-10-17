import React, {ChangeEvent, Component, InputHTMLAttributes, useState} from "react";
import Papa from "papaparse";

import "../../assets/Setup.scss"
import { CJMS_POST_EVENT, Requests } from "@cjms_interfaces/shared";
import { IEvent, initIEvent, request_namespaces } from "@cjms_shared/services";
import Select from "react-select";
import Games from "ausfll-score-calculator";

interface SelectOption {
  value:any,
  label:string
}

interface IProps {}
interface IState {
  csv:any;
  eventName:string;
  season_options:SelectOption[];
  selected_season:number;
  rounds:number;
  match_locked:boolean;
}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      csv:null,
      eventName:"",
      season_options: [],
      selected_season: 0,
      rounds: 3,
      match_locked: true
    }

    this.updateCSV = this.updateCSV.bind(this);
    this.sendSetup = this.sendSetup.bind(this);
    this.onEventNameChange = this.onEventNameChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.onPurge = this.onPurge.bind(this);
  }

  setSeasonOptions(options:SelectOption[]) {
    this.setState({season_options: options});
  }

  setSelectedSeason(value:number) {
    this.setState({selected_season: value});
  }

  componentDidMount(): void {
    var options:SelectOption[] = Games.Games.map(({name, season}) => ({label: name, value: season}));
    this.setSeasonOptions(options);
    this.setSelectedSeason(Games.Games[0].season);
  }

  sendSetup() {
    var event:IEvent = initIEvent();

    event.event_csv = this.state.csv;
    event.event_name = this.state.eventName;
    event.season = this.state.selected_season;
    event.event_rounds = this.state.rounds;
    event.match_locked = this.state.match_locked;

    CJMS_POST_EVENT(event);
    window.location.reload();
  }

  sendPurge() {
    Requests.CJMS_FETCH_GENERIC_GET(request_namespaces.request_post_purge);
  }

  updateCSV(result:any) {
    this.setState({csv:result.data});
    console.log(result.data);
  }

  onRoundsChange(e:ChangeEvent<HTMLInputElement>) {
    this.setState({rounds: Number(e.target.value)});
  }

  onMatchLockChange(e:ChangeEvent<HTMLInputElement>) {
    this.setState({match_locked: Boolean(e.target.checked)});
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

            {/* FLL Season */}
            <h3>Season (default: latest)</h3>
            <Select
              options={this.state.season_options}
              value={this.state.season_options.find((season) => season.value === this.state.selected_season)}
              onChange={(season) => this.setSelectedSeason(Number(season?.value))}
            />

            {/* Event rounds */}
            <h3>Event Rounds (default 3)</h3>
            <input type={"number"} onChange={(e) => this.onRoundsChange(e)} placeholder="rounds..." defaultValue={3}/>

            <h3>Match Locked</h3>
            <input type={"checkbox"} onChange={(e) => this.onMatchLockChange(e)} defaultChecked={true}/>

            {/* Controls */}
            <button className="hoverButton back-red" onClick={this.onPurge}>Purge Database</button>
            <button className="hoverButton back-green" onClick={this.onSubmit}>Submit</button>
          </form>

        </div>
      </div>
    );
  }
}