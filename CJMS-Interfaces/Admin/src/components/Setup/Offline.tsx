import { Component, ChangeEvent } from "react";
import Papa from "papaparse";

import { CJMS_POST_SETUP, Requests } from "@cjms_interfaces/shared";
import { IEvent, initIEvent, request_namespaces } from "@cjms_shared/services";
import Select from "react-select";
import Games from "ausfll-score-calculator";
import { FormControlLabel, Radio, RadioGroup } from "@mui/material";

import "../../assets/Setup.scss";

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

export default class Offline extends Component<IProps, IState> {
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

  componentDidMount(): void {
    var options:SelectOption[] = Games.Games.map(({name, season}) => ({label: name, value: season}));
    this.setSeasonOptions(options);
    this.setSelectedSeason(Games.Games[0].season);
  }

  setSeasonOptions(options:SelectOption[]) {
    this.setState({season_options: options});
  }

  setSelectedSeason(value:number) {
    this.setState({selected_season: value});
  }

  onEventNameChange(e:ChangeEvent<HTMLInputElement>) {
    e.preventDefault();
    this.setState({eventName:e.target.value});
  }

  updateCSV(result:any) {
    this.setState({csv:result.data});
  }

  onScheduleImport(e:ChangeEvent<HTMLInputElement>) {
    e.preventDefault();
    const f:any = (e.target as HTMLInputElement).files?.[0];
    Papa.parse(f, {header:false, skipEmptyLines:true, complete:this.updateCSV});
  }

  onRoundsChange(e:ChangeEvent<HTMLInputElement>) {
    this.setState({rounds: Number(e.target.value)});
  }

  sendSetup() {
    var event:IEvent = initIEvent();

    event.event_name = this.state.eventName;
    event.event_csv = this.state.csv;
    event.season = this.state.selected_season;
    event.event_rounds = this.state.rounds;
    event.match_locked = this.state.match_locked;

    CJMS_POST_SETUP(event);
    window.location.reload();
  }

  sendPurge() {
    Requests.CJMS_FETCH_GENERIC_GET(request_namespaces.request_post_purge);
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
    return (
      <div className="setup-column">
        <form onSubmit={(e) => {e.preventDefault()}}>
          <p>Offline Setup</p>
          <ol>
            <li>Import CSV</li>
            <li>Select Season</li>
            <li>Enter Event Name</li>
            <li>Set round numbers</li>
            <li>Set default match lock state</li>
          </ol>
          {/* Schedule import */}
          <h3>Schedule</h3>
          <input 
            type={"file"}
            id={"scheduleImport"}
            accept={".csv"}
            onChange={(e) => this.onScheduleImport(e)}
            className="import-button"
          />
          or - <a href="https://firstaustralia.org/fll-scheduler/">Generate Schedule/CSV</a><br/>

          {/* FLL Season */}
          <h3>Season (default: latest)</h3>
          <Select
            options={this.state.season_options}
            value={this.state.season_options.find((season) => season.value === this.state.selected_season)}
            onChange={(season) => this.setSelectedSeason(Number(season?.value))}
          />

          {/* Main Event Name */}
          <h3>Event Name</h3>
          <input onChange={(e) => this.onEventNameChange(e)} placeholder="event name..."/>

          {/* Event rounds */}
          <h3>Event Rounds (default 3)</h3>
          <input type={"number"} onChange={(e) => this.onRoundsChange(e)} placeholder="rounds..." defaultValue={3}/>

          <h3>Match Locked</h3>
          <RadioGroup row defaultValue={true}>
            <FormControlLabel value={true} defaultChecked={true} control={<Radio />} label="Match Lock"/>
            <FormControlLabel value={false} control={<Radio />} label="Match Free"/>
          </RadioGroup>

          {/* Controls */}
          <button className="hoverButton back-red" onClick={this.onPurge}>Purge Database</button>
          <button className="hoverButton back-green" onClick={this.onSubmit}>Submit</button>
        </form>
      </div>
    );
  }
}