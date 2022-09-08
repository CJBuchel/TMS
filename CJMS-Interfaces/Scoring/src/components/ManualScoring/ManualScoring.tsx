import { CJMS_FETCH_GENERIC_GET, CJMS_FETCH_GENERIC_POST } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";
import React, { Component } from "react";
import Select, { SingleValue } from "react-select";

import "../../assets/ScoringApp.scss";

interface SelectOption {
  value:any,
  label:string
}

interface IProps {
  scorer:any;
  table:any;
}

interface IState {
  // External data
  external_eventData:any;
  external_teamData:any;

  // Internal Set data
  form_TeamNumber?:string;
  form_RoundNumber?:number;
  form_TeamScore?:number;
  form_TeamGP?:number;
  form_TeamNotes:any;

  options_teams?:SelectOption[];
  options_rounds?:SelectOption[];
}

const options_gp = [
  {value: 2, label: "Developing 2"},
  {value: 3, label: "Accomplished 3"},
  {value: 4, label: "Exceeds 4"}
];

export default class ManualScoring extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      external_eventData: undefined,
      external_teamData: undefined,
      form_TeamNotes: '',
    }

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  setExternalData(eventData:any, teamData:any) {
    this.setState({external_eventData: eventData.data, external_teamData: teamData.data});

    const team_options:SelectOption[] = [];
    const round_options:SelectOption[] = [];

    for (const team of teamData.data) {
      team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
    }

    for (var i = 1; i < eventData.data.event_rounds+1; i++) {
      round_options.push({value: i, label: `Round ${i}`});
    }

    this.setState({options_teams: team_options});
    this.setState({options_rounds: round_options});
  }

  async componentDidMount() {
    const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
    this.setExternalData(eventData, teamData);

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setExternalData(eventData, teamData);
    });

    comm_service.listeners.onTeamUpdate(async () => {
      const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, true);
      this.setExternalData(eventData, teamData);
    });
  }

  onSelectTeam(e:SingleValue<SelectOption>) {
    this.setState({form_TeamNumber: e?.value});
  }

  onSelectRound(e:SingleValue<SelectOption>) {
    this.setState({form_RoundNumber: e?.value});
  }

  onScoreChange(e:React.ChangeEvent<HTMLInputElement>) {
    this.setState({form_TeamScore: Number(e.target.value)});
  }

  onGPChange(e:SingleValue<SelectOption>) {
    this.setState({form_TeamGP: e?.value});
  }

  onNotesChange(e:React.ChangeEvent<HTMLInputElement>) {
    this.setState({form_TeamNotes: e.target.value});
  }

  handleClear() {
    window.location.reload();
  }

  handleNoShow() {
    
  }

  async handleSubmit() {
    const result:any = await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_score, {
      team_number: this.state.form_TeamNumber,
      round: this.state.form_RoundNumber,
      score: this.state.form_TeamScore,
      gp: this.state.form_TeamGP,
      notes: this.state.form_TeamNotes,
      scored_by: this.props.scorer
    });

    if (result.success) {
      alert("Successfully updated team");
      window.location.reload();
    }
  }

  render() {
    if (this.state.external_teamData) {
      return(
        <div className="manual">
          <form onSubmit={(e) => {e.preventDefault()}}>
  
            {/* Team Select */}
            <label>Select Team</label>
            <Select onChange={(e) => this.onSelectTeam(e)} options={this.state.options_teams}/>
  
            {/* Round Number */}
            <label>Round Number</label>
            <Select onChange={(e) => this.onSelectRound(e)} options={this.state.options_rounds}/>
  
            {/* Score */}
            <label>Score</label>
            <input type={"number"} onChange={(e) => this.onScoreChange(e)} />
  
            {/* GP */}
            <label>GP</label>
            <Select onChange={(e) => this.onGPChange(e)} options={options_gp}/>
  
            {/* Notes */}
            <label>Notes</label>
            <input onChange={(e) => this.onNotesChange(e)}/>
            
            <div className="buttons">
              {/* No Show */}
              <button onClick={this.handleNoShow} disabled={(!this.state.form_TeamNumber || !this.state.form_RoundNumber)} className={`hoverButton ${(!this.state.form_TeamNumber || !this.state.form_RoundNumber) ? "" : "back-orange"}`}>No Show</button>
            </div>
  
            <div className="buttons">
              {/* Clear */}
              <button onClick={this.handleClear} type="reset" className="hoverButton back-red">Clear</button>
            </div>
  
            <div className="submitButton">
              {/* Submit Button */}
              <button onClick={this.handleSubmit} disabled={(!this.state.form_TeamNumber || !this.state.form_RoundNumber || !this.state.form_TeamScore || !this.state.form_TeamGP)} className={`hoverButton ${(!this.state.form_TeamNumber || !this.state.form_RoundNumber || !this.state.form_TeamScore || !this.state.form_TeamGP) ? "" : "back-green"}`}>Submit</button>
            </div>
  
          </form>
        </div>
      );
    } else {
      return(
        <div className="waiting-message">
          <div className="loader"></div>
          <h2>Waiting For Event Data</h2>
        </div>
      );
    }
  }
}