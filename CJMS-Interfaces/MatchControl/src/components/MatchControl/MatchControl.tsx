import { Component } from "react";

import "../../assets/stylesheets/MatchControl.scss";

import { Controls } from "./Controls";
import { MatchTable } from "./Table";

interface IProps {
  external_teamData:any[];
  external_matchData:any[];
}

interface IState {
  selected_match:any;
}

export default class MatchControl extends Component<IProps, IState> {

  constructor(props:any) {
    super(props);

    this.state = {
      selected_match: undefined
    }

    this.setSelectedMatch = this.setSelectedMatch.bind(this);
  }

  setSelectedMatch(match_number:string) {
    const match = this.props.external_matchData.find(e => e.match_number == match_number);
    console.log(match);
    this.setState({selected_match: match});
  }

  render() {
    return (
      <div className="match-control">
        <div className="match-control-row">
          <div className="match-control-controls">
            <Controls external_matchData={this.props.external_matchData} external_teamData={this.props.external_teamData} selected_match={this.state.selected_match}/>
          </div>

          <div className="match-control-matches">
            <MatchTable external_matchData={this.props.external_matchData} setSelectedMatch={this.setSelectedMatch}/>
          </div>
        </div>
      </div>
    );
  }
}