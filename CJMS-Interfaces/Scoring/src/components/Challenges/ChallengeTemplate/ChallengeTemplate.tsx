import { Component } from "react";
import Select, { SingleValue } from "react-select";

import "../../../assets/Challenge.scss";

interface SelectOption {
  value:any;
  label:string;
}

interface IProps {
  scorer:any;
  table:any;

  eventData:any;
  teamData:any;
  matchData:any;
}

interface IState {
  options_teams:SelectOption[];
  selected_team:SelectOption;
  selected_match:string;
  table_matches:any[];
}

export default class ChallengeTemplate extends Component<IProps,IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      options_teams:[],
      selected_team: {value: '', label: ''},
      selected_match: '',
      table_matches: [],
    }
  }

  setOptions() {
    const team_options:SelectOption[] = [];
    const matches:any[] = [];
    for (const team of this.props.teamData) {
      team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
    }

    for (const match of this.props.matchData) {
      if (match.on_table1.table === this.props.table || match.on_table2.table === this.props.table) {
        matches.push(match);
      }
    }

    const nextMatch = matches.find(e => !e.complete);
    const on_table = nextMatch.on_table1.table === this.props.table ? nextMatch.on_table1 : nextMatch.on_table2;

    const nextTeam = team_options.find(e => e.value == on_table.team_number) || {value: '', label: ''};
    this.setState({options_teams: team_options, table_matches: matches, selected_team: nextTeam, selected_match: nextMatch.match_number});
  }

  async componentDidMount() {
    this.setOptions();
  }

  handleTeamChange(value:any) {
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
            <h1>Match #{this.state.selected_match}</h1>
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