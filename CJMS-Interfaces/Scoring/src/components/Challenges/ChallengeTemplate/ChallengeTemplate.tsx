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
  event_data:EventData
}

interface IState {
  options_teams:SelectOption[];
  table_matches:any[];

  loaded_team:SelectOption;
  loaded_match:string;
  calculated_score:number;
}

export default class ChallengeTemplate extends Component<IProps,IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      options_teams:[],
      table_matches: [],
      calculated_score: 0,

      loaded_team: {value: '', label: ''},
      loaded_match: ''
    }
  }

  // setOptions() {
  //   const team_options:SelectOption[] = [];
  //   const matches:any[] = [];
  //   for (const team of this.props.teamData) {
  //     team_options.push({value: team.team_number, label: `${team.team_number} | ${team.team_name}`});
  //   }

  //   for (const match of this.props.matchData) {
  //     if (match.on_table1.table === this.props.table || match.on_table2.table === this.props.table) {
  //       matches.push(match);
  //     }
  //   }

  //   this.setState({options_teams: team_options, table_matches: matches});
  // }

  // setLoadedMatch(match:string) {
  //   console.log(match);
  //   const match_loaded = this.state.table_matches.find(e => e.match_number == match);
  //   const loaded_team_number = match_loaded?.on_table1.table == this.props.table ? match_loaded?.on_table1.team_number : match_loaded?.on_table2.team_number;
  //   const team_loaded = this.props.teamData.find(e => e.team_number == loaded_team_number);

  //   console.log(match_loaded);
  //   console.log(team_loaded);

  //   if (team_loaded != undefined || team_loaded != null) {
  //     // this.setState({
  //     //   loaded_team: {value: team_loaded.team_number, label: team_loaded.team_name},
  //     //   loaded_match: match_loaded.match_number
  //     // });
  //     this.setState({loaded_team: {value: team_loaded.team_number, label: team_loaded.team_name}});
  //     this.setState({loaded_match: match_loaded.match_number});
  //   }

  // }

  componentDidMount() {
    // this.setOptions();
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
            <h1>Match #<span>{this.state.loaded_match}</span></h1>
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