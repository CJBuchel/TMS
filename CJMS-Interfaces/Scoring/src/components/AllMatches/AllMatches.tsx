import { Component } from "react";

import "../../assets/MatchTable.scss";

interface IProps {
  external_teamData:any[];
  external_matchData:any[];
}

interface IState {}

export default class AllMatches extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  getTableHeaders() {
    return (
      <tr>
        <th>Match Number</th>
        <th>Start Time</th>
        <th>On Table</th>
        <th>Team Number</th>
        <th>On Table</th>
        <th>Team Number</th>
      </tr>
    )
  }

  getTable() {
    const content:any[] = [];

    if (this.props.external_matchData.length > 0) {
      for (const match of this.props.external_matchData) {
        content.push(
          <tr
            id={match.match_number}
            key={match.match_number}
            style={{
              backgroundColor: `${match.complete ? 'green' : ''}`,
            }}
          >
            <td>#{match.match_number}</td>
            <td>{match.start_time}</td>
            {/* Team 1 */}
            <td style={{backgroundColor: `${match.complete ? (match.on_table1.score_submitted ? '' : 'red') : ''}`}}>{match.on_table1.table}</td>
            <td style={{backgroundColor: `${match.complete ? (match.on_table1.score_submitted ? '' : 'red') : ''}`}}>{match.on_table1.team_number}</td>
            {/* Team 2 */}
            <td style={{backgroundColor: `${match.complete ? (match.on_table2.score_submitted ? '' : 'red') : ''}`}}>{match.on_table2.table}</td>
            <td style={{backgroundColor: `${match.complete ? (match.on_table2.score_submitted ? '' : 'red') : ''}`}}>{match.on_table2.team_number}</td>
          </tr>
        );
      }
    }

    return content;
  }

  render() {
    return (
      <div className="table-wrapper">
        <table className="mt-table">
          <thead>{this.getTableHeaders()}</thead>
          <tbody>{this.getTable()}</tbody>
        </table>
      </div>
    );
  }
}