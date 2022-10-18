import React, {ChangeEvent, Component, InputHTMLAttributes, useState} from "react";
import Papa from "papaparse";

import "../../assets/Setup.scss"
import { CJMS_POST_EVENT, Requests, CLOUD_REQUEST_TOURNAMENTS, CLOUD_REQUEST_TEAMS, CLOUD_REQUEST_SCORESHEETS, CJMS_REQUEST_TEAMS } from "@cjms_interfaces/shared";
import { IEvent, initIEvent, ITeam, request_namespaces } from "@cjms_shared/services";
import Select from "react-select";
import Games from "ausfll-score-calculator";
import { FormControlLabel, Radio, RadioGroup } from "@mui/material";

interface SelectOption {
  value:any,
  label:string
}

interface IProps {}
interface IState {
  csv:any;
  eventName:string;
  season_options:SelectOption[];
  tournament_options:SelectOption[];
  selected_season:number;
  selected_tournament:string;
  rounds:number;
  match_locked:boolean;
  link_using_team_names:boolean;
  link_state:string[];
  linked:boolean;
  tournaments:any[];
}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      csv:null,
      eventName:"",
      season_options: [],
      tournament_options: [],
      selected_season: 0,
      selected_tournament: "0",
      rounds: 3,
      match_locked: true,
      link_using_team_names: false,
      link_state: ["Unlinked"],
      linked: false,
      tournaments: []
    }

    this.updateCSV = this.updateCSV.bind(this);
    this.sendSetup = this.sendSetup.bind(this);
    this.onEventNameChange = this.onEventNameChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.onPurge = this.onPurge.bind(this);
    this.onLink = this.onLink.bind(this);
  }

  setSeasonOptions(options:SelectOption[]) {
    this.setState({season_options: options});
  }

  setSelectedSeason(value:number) {
    this.setState({selected_season: value});
  }

  setSelectedTournament(value:string) {
    this.setState({selected_tournament: value});
  }

  setupOptions(res:any) {
    var temp_tournys:any[] = res;
    var options:SelectOption[] = temp_tournys.filter(e => e.program === "FLL_CHALLENGE").filter(e => e.season === this.state.selected_season).map(({name, _id}) => ({label: name, value: _id}));
    // console.log(temp_tournys);
    this.setState({tournament_options: options});
  }

  componentDidMount(): void {
    var options:SelectOption[] = Games.Games.map(({name, season}) => ({label: name, value: season}));
    this.setSeasonOptions(options);
    this.setSelectedSeason(Games.Games[0].season);

    CLOUD_REQUEST_TOURNAMENTS().then((res:any) => {
      this.setupOptions(res);
    });
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

  onLink() {
    CLOUD_REQUEST_TEAMS(this.state.selected_tournament).then((cloud_teams:any) => {
      CJMS_REQUEST_TEAMS().then((teams) => {
        if (teams.length != cloud_teams.length) {
          alert("Invalid cross reference. Team lengths differ");
        }
        const matching_teams:ITeam[] = [];
        const unmatched_teams:string[] = [];
        for (const team of cloud_teams) {
          const cloud_t_number = `AU-${team.team_number}C`;
          const t = this.state.link_using_team_names ? teams.find(e => e.team_name == team.team_name) : teams.find(e => e.team_number == cloud_t_number);
          if (t != undefined) {
            matching_teams.push(t);
          } else {
            unmatched_teams.push(`${team.team_number} | ${team.team_name}`);
          }
        }

        if (matching_teams.length != teams.length) {
          alert("Some teams failed to match");
          // filter teams that weren't matched and display them;
          this.setState({linked: false});
          this.setState({link_state: unmatched_teams});
        } else {
          this.setState({linked: true});
          this.setState({link_state: ["Linked to tournament_id: " + this.state.selected_tournament]});
        }

        console.log(matching_teams);
      });
    });
  }

  render() {
    return(

      <div className="setup-main">
        <div className="setup-row">
          <div className="setup-column">
            {/* Main Form */}
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
              {/* <input type={"checkbox"} onChange={(e) => this.onMatchLockChange(e)} defaultChecked={true}/> */}

              {/* Controls */}
              <button className="hoverButton back-red" onClick={this.onPurge}>Purge Database</button>
              <button className="hoverButton back-green" onClick={this.onSubmit}>Submit</button>
            </form>
          </div>

          <div className="setup-column online">
            {/* Main Form */}
            <form onSubmit={(e) => {e.preventDefault()}}>
              <p>Online Link (optional)</p>
              <ol>
                <li>Complete Offline Setup</li>
                <li>Select/Search For Event</li>
              </ol>

              {/* FLL Season */}
              <h3>Tournament</h3>
              <Select
                options={this.state.tournament_options}
                placeholder={`${this.state.tournament_options.length > 0 ? 'Select Tournament' : 'Offline'}`}
                onChange={(tourny) => this.setSelectedTournament(String(tourny?.value))}
              />

              <h3>Cross reference schedule using:</h3>
              <RadioGroup row defaultValue={true}>
                <FormControlLabel value={true} defaultChecked={true} control={<Radio />} label="Team Numbers (Format: AU-000C)"/>
                <FormControlLabel value={false} control={<Radio />} label="Team Names"/>
              </RadioGroup>


              {/* Controls */}
              <button className="hoverButton back-blue" onClick={this.onLink}>Link</button>

              <h2>Link Status:</h2>
              {this.state.link_state.map((i) => (
                <p><span style={{color: this.state.linked ? 'green' : 'red'}}>{i}</span></p>
              ))}
            </form>

          </div>
        </div>
      </div>

    );
  }
}