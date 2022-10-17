import { IEvent, IMatch, initITeam, initITeamScore, ITeam, ITeamScore, request_namespaces } from "@cjms_shared/services";
import { Component } from "react";
import Select from "react-select";
import { Challenges } from "./Containers";

import "../../assets/Challenge.scss";
import { CJMS_FETCH_GENERIC_POST, CJMS_POST_SCORE, CJMS_REQUEST_MATCHES } from "@cjms_interfaces/shared";

interface SelectOption {
  value:any;
  label:string;
}

export interface MatchData {
  table_matches:IMatch[];
  loaded_team:ITeam;
  loaded_match:IMatch;
  match_locked:boolean;
}

export interface EventData {
  eventData:IEvent;
  teamData:ITeam[];
  matchData:IMatch[];
}

interface IProps {
  scorer:string;
  table:string;

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

export default class ChallengeScoring extends Component<IProps,IState> {
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

    this.handleScoreChange = this.handleScoreChange.bind(this);
    this.handleScoreSubmit = this.handleScoreSubmit.bind(this);
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

  async handleScoreSubmit(scoresheet:ITeamScore) {
    // score reqs
    scoresheet.referee = this.props.scorer;
    scoresheet.valid_scoresheet = true;

    // team specifics
    scoresheet.scoresheet.team_id = this.state.selected_team.value;
    scoresheet.scoresheet.round = this.state.selected_round.value;

    // Get the current match and update it to complete/submitted for this table
    const match = (await CJMS_REQUEST_MATCHES(true)).find(e => e.match_number === this.props.match_data.loaded_match.match_number);
    if (match != undefined) {
     
      var match_update = match;
      if (match.on_table1.team_number == scoresheet.scoresheet.team_id) {
        match_update.on_table1.score_submitted = true;
      } else if (match.on_table2.team_number == scoresheet.scoresheet.team_id) {
        match_update.on_table2.score_submitted = true;
      } else {
        window.alert("Team does not exist in this match");
        return;
      }
  
      const submit_result:any = await CJMS_POST_SCORE(scoresheet);
      const match_result:any = await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_update, {
        match: match.match_number,
        update: match_update
      });
  
      // Return check from server
      if (submit_result.success && match_result.success) {
        alert("Successfully updated team");
        window.location.reload();
      } else {
        alert("Submit failed");
      }
    } else {
      alert("Match undefined");
    }
  }

  handleScoreChange(score:number) {
    this.setState({calculated_score: score});
  }

  handleRoundChange(value:any) {
    this.setState({selected_round: value});
  }

  handleTeamChange(value:any) {
    const team:ITeam = this.props.event_data.teamData.find(e => e.team_number == value.value) || initITeam();
    var round = 0;
  
    if (team.scores.length > 0) {
      for (const score of team.scores) {
        round = score.scoresheet.round >= round ? score.scoresheet.round + 1 : round;
      }
    } else {
      round = 1;
    }

    this.handleRoundChange({value: round, label: `Auto Round ${round}`});
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
            <h2>Next Match: <span style={{color: "green"}}>#{this.state.selected_match}</span></h2>
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
        <Challenges 
          handleScoreSubmit={this.handleScoreSubmit} 
          handleScoreChange={this.handleScoreChange}
          event_data={this.props.event_data.eventData}
        />
      </div>
    );
  }
}