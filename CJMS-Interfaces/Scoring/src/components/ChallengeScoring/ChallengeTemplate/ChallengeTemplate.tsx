import { comm_service } from "@cjms_interfaces/shared";
import { Component } from "react";
import Select, { SingleValue } from "react-select";

import "../../../assets/Challenge.scss";

interface SelectOption {
  value:any;
  label:string;
}

export interface MatchData {
  table_matches:any[];
  loaded_team:any;
  loaded_match:any;
  match_locked:boolean;
}

export interface EventData {
  eventData:any;
  teamData:any[];
  matchData:any[];
}

interface IProps {
  scorer:any;
  table:any;

  match_data:MatchData;
  event_data:EventData;
}

interface IState {
  options_teams:SelectOption[];
  options_rounds:SelectOption[];

  selected_team:SelectOption;
  selected_round:SelectOption;
  selected_match:string;
  calculated_score:number;
}

export default class ChallengeTemplate extends Component<IProps,IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      options_teams:[],
      options_rounds:[],
      calculated_score: 0,

      selected_round: {value: '', label: ''},
      selected_team: {value: '', label: ''},
      selected_match: ''
    }
  }

  setOptions() {
    const team_options:SelectOption[] = [];
    const round_options:SelectOption[] = [];
    for (const team of this.props.event_data.teamData) {
      team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
    }

    for (var i = 0; i < this.props.event_data.eventData.event_rounds; i++) {
      round_options.push({value: (i+1), label: `Round ${i+1}`});
    }

    if (this.props.match_data.match_locked) {
      this.handleTeamChange({
        value: this.props.match_data.loaded_team.team_number, 
        label: `${this.props.match_data.loaded_team.team_number} | ${this.props.match_data.loaded_team.team_name}`
      });
      
      this.setState({selected_match: this.props.match_data.loaded_match.match_number});
    }

    this.setState({options_teams: team_options, options_rounds: round_options});
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (prevProps != this.props) {
      this.setOptions();
    }
  }

  componentDidMount() {
    this.setOptions();
  }

  handleRoundChange(value:any) {
    this.setState({selected_round: value});
  }

  handleTeamChange(value:any) {
    const team = this.props.event_data.teamData.find(e => e.team_number == value.value);
    
    var round = 0;
    if (team.scores.length > 0) {
      for (const score of team.scores) {
        console.log(score.roundIndex);
        round = score.roundIndex >= round ? score.roundIndex + 1 : round;
      }
    } else {
      round = 1;
    }

    this.handleRoundChange({value: round, label: `Auto Round ${round}`});
    
    console.log(team);
    console.log(round);
    this.setState({selected_team: value});
  }

  renderScoreBar() {
    return(
      <div className="score-bar">
        <div className="score-bar-column">
          <div className="score-bar-content">
            <Select 
              options={this.state.options_teams}
              value={this.state.selected_team}
              onChange={(value) => this.handleTeamChange(value)}
            />
          </div>
        </div>

        <div className="score-bar-column">
          <div className="score-bar-content">
            <Select 
              options={this.state.options_rounds}
              value={this.state.selected_round}
              onChange={(value) => this.handleRoundChange(value)}
            />
          </div>
        </div>
        
        <div className="score-bar-column">
          <div className="score-bar-content">
            <h2>Match <span style={{color: "green"}}>#{this.state.selected_match}</span></h2>
          </div>
        </div>

        <div className="score-bar-column">
          <div className="score-bar-content">
            <h2>Score: <span style={{color: "green"}}>{this.state.calculated_score}</span></h2>
          </div>
        </div>
      </div>
    );
  }

  render() {
    return(
      <div className="challenge-scoring">
        {this.renderScoreBar()}
        <p>Big REE</p>
      </div>
    );
  }
}