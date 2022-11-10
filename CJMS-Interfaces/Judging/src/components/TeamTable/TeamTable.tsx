import { IEvent, IMatch, ITeam } from "@cjms_shared/services";
import { Component } from "react";

interface IProps {
  external_eventData:IEvent;
  external_matchData:IMatch[];
  external_teamData:ITeam[];
}

interface IState {}

export default class TeamTable extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  getRoundHeaders() {
    const round_headers:string[] = [];
    for (var i = 0; i < this.props.external_eventData.event_rounds; i++) {
      round_headers.push(`R${i+1}`); // score
      round_headers.push(`GP${i+1}`); // gp
    }

    return (
      round_headers.map((header, i) => (<th key={i}>{header}</th>))
    )
  }

  getTableHeaders() {
    return (
      <tr>
        <th>Rank</th>
        <th>Team Number</th>
        <th>Team Name</th>
        {this.getRoundHeaders()}
      </tr>
    );
  }

  getTableScores(team:ITeam) {
    var table_scores:string[] = [];
    for (var i = 0; i < this.props.external_eventData.event_rounds; i++) {
      if (team.scores[i]) {
        table_scores.push(team.scores[i].score.toString());
        table_scores.push(team.scores[i].gp.toString());
      } else {
        table_scores.push('');
        table_scores.push('');
      }
    }

    return (
      table_scores.map((score, i) => (<td key={i}>{`${score}`}</td>))
    );
  }

  getTable() {
    return (
      this.props.external_teamData.map((team) => (
        <tr key={team.team_number}>
          <td>{team.ranking}</td>
          <td>{team.team_number}</td>
          <td>{team.team_name}</td>
          {this.getTableScores(team)}
        </tr>
      ))
    );
  }

  render() {
    return (
      <table className="mt-table">
        <thead>{this.getTableHeaders()}</thead>
        <tbody>{this.getTable()}</tbody>
      </table>
    );
  }
}