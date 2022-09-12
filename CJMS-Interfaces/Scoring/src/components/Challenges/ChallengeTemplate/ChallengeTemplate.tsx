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

  loaded_team:SelectOption;
  loaded_match:string;
  calculated_score:number;
}

export default class ChallengeTemplate extends Component<IProps,IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      options_teams:[],
      calculated_score: 0,

      loaded_team: {value: '', label: ''},
      loaded_match: ''
    }

  }

  setOptions() {
    const team_options:SelectOption[] = [];
    for (const team of this.props.event_data.teamData) {
      team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
    }

    this.setState({
      loaded_match: this.props.match_data.loaded_match.match_number,
      loaded_team: {
        value: this.props.match_data.loaded_team.team_number, 
        label: `${this.props.match_data.loaded_team.team_number} | ${this.props.match_data.loaded_team.team_name}`
      }
    });

    this.setState({options_teams: team_options});
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (prevProps != this.props) {
      this.setOptions();
    }
  }

  componentDidMount() {
    this.setOptions();
  }

  handleTeamChange(value:any) {
    this.setState({loaded_team: value});
  }

  renderScoreBar() {
    return(
      <div className="score-bar">
        <div className="score-bar-column">
          <div className="score-bar-content">
            <Select 
              options={this.state.options_teams}
              value={this.state.loaded_team}
              onChange={(value) => this.handleTeamChange(value)}
            />
          </div>
        </div>
        
        <div className="score-bar-column">
          <div className="score-bar-content">
            <h1>Match <span style={{color: "green"}}>#{this.state.loaded_match}</span></h1>
          </div>
        </div>

        <div className="score-bar-column">
          <div className="score-bar-content">
            <h1>Score: <span style={{color: "green"}}>{this.state.calculated_score}</span></h1>
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