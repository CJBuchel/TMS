import { CJMS_POST_SCORE, CJMS_FETCH_GENERIC_POST } from "@cjms_interfaces/shared";
import { comm_service, request_namespaces, ITeamScore, IEvent, ITeam, IMatch, initIMatch, initITeamScore } from "@cjms_shared/services";
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

  eventData:IEvent;
  teamData:ITeam[];
  matchData:IMatch[];
}

interface IState {
  // Internal Set data
  form_MatchNumber?:string;
  team_scoresheet:ITeamScore;

  options_teams?:SelectOption[];
  options_rounds?:SelectOption[];
  options_matches?:SelectOption[];
}

const options_gp = [
  {value: "2 - Developing", label: "2 - Developing"},
  {value: "3 - Accomplished", label: "3 - Accomplished"},
  {value: "4 - Exceeds", label: "4 - Exceeds"}
];

export default class ManualScoring extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);


    this.state = {
      team_scoresheet: initITeamScore(),
    }
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  setInternalData() {
    const team_options:SelectOption[] = [];
    const round_options:SelectOption[] = [];
    const match_options:SelectOption[] = [];

    for (const team of this.props.teamData) {
      team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
    }

    for (var i = 1; i < this.props.eventData.event_rounds+1; i++) {
      round_options.push({value: i, label: `Round ${i}`});
    }

    for (const match of this.props.matchData) {
      match_options.push({value: match.match_number, label: match.match_number});
    }

    this.setState({options_teams: team_options});
    this.setState({options_rounds: round_options});
    this.setState({options_matches: match_options});
  }

  async componentDidMount() {
    this.setInternalData();
  }

  onSelectTeam(e:SingleValue<SelectOption>) {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.scoresheet.team_id = e?.value;
    this.setState({team_scoresheet: scoresheet});
  }

  onSelectRound(e:SingleValue<SelectOption>) {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.scoresheet.round = e?.value;
    this.setState({team_scoresheet: scoresheet});
  }

  onSelectMatch(e:SingleValue<SelectOption>) {
    this.setState({form_MatchNumber: e?.value});
  }

  onScoreChange(e:React.ChangeEvent<HTMLInputElement>) {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.score = Number(e.target.value);
    this.setState({team_scoresheet: scoresheet});
  }

  onGPChange(e:SingleValue<SelectOption>) {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.gp = e?.value;
    this.setState({team_scoresheet: scoresheet});
  }

  onNotesChange(e:React.ChangeEvent<HTMLInputElement>) {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.scoresheet.private_comment = e.target.value;
    this.setState({team_scoresheet: scoresheet});
  }

  handleClear() {
    window.location.reload();
  }

  handleNoShow() {
    var scoresheet = this.state.team_scoresheet;
    scoresheet.no_show = true;
    this.setState({team_scoresheet: scoresheet});
  }

  async handleSubmit() {
    const match = this.props.matchData.find(e => e.match_number == this.state.form_MatchNumber) || initIMatch();
    var update = match;
    if (match.on_table1.team_number == this.state.team_scoresheet.scoresheet.team_id) {
      update.on_table1.score_submitted = true;
    } else if (match.on_table2.team_number == this.state.team_scoresheet.scoresheet.team_id) {
      update.on_table2.score_submitted = true;
    } else {
      window.alert("Team does not exist in this match");
      return;
    }

    var scoresheet = this.state.team_scoresheet;
    scoresheet.referee = this.props.scorer;
    this.setState({team_scoresheet: scoresheet});

    const submit_result:any = await CJMS_POST_SCORE(scoresheet);
    const match_result:any = await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_update, {
      match: this.state.form_MatchNumber,
      update: update
    });

    if (submit_result.success && match_result.success) {
      alert("Successfully updated team");
      window.location.reload();
    }
  }

  render() {
    return(
      <div className="manual">
        <form onSubmit={(e) => {e.preventDefault()}}>

          {/* Team Select */}
          <label>Select Team</label>
          <Select onChange={(e) => this.onSelectTeam(e)} options={this.state.options_teams}/>

          {/* Round Number */}
          <label>Round Number</label>
          <Select onChange={(e) => this.onSelectRound(e)} options={this.state.options_rounds}/>

          {/* Match Number */}
          <label>Match Number</label>
          <Select onChange={(e) => this.onSelectMatch(e)} options={this.state.options_matches}/>

          {/* Score */}
          <label>Score</label>
          <input type={"number"} onChange={(e) => this.onScoreChange(e)}/>

          {/* GP */}
          <label>GP</label>
          <Select onChange={(e) => this.onGPChange(e)} options={options_gp}/>

          {/* Notes */}
          <label>Notes</label>
          <input onChange={(e) => this.onNotesChange(e)}/>
          
          <div className="buttons">
            {/* No Show */}
            <button onClick={this.handleNoShow} disabled={(!this.state.team_scoresheet.scoresheet.team_id || !this.state.team_scoresheet.scoresheet.round)} className={`hoverButton ${(!this.state.team_scoresheet.scoresheet.team_id || !this.state.team_scoresheet.scoresheet.round) ? "" : "back-orange"}`}>No Show</button>
          </div>

          <div className="buttons">
            {/* Clear */}
            <button onClick={this.handleClear} type="reset" className="hoverButton back-red">Clear</button>
          </div>

          <div className="submitButton">
            {/* Submit Button */}
            <button onClick={this.handleSubmit} disabled={
              (
                !this.state.team_scoresheet.scoresheet.team_id || 
                !this.state.team_scoresheet.scoresheet.round || 
                !this.state.team_scoresheet.score || 
                !this.state.team_scoresheet.gp)
            } className={
              `hoverButton ${(
                !this.state.team_scoresheet.scoresheet.team_id || 
                !this.state.team_scoresheet.scoresheet.round || 
                !this.state.team_scoresheet.score || 
                !this.state.team_scoresheet.gp) ? "" : "back-green"}`
            }>Submit</button>
          </div>
        </form>
      </div>
    );
  }
}