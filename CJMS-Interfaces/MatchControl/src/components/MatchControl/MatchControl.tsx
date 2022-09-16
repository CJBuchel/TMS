import { Component } from "react";

import "../../assets/stylesheets/MatchControl.scss";
import "../../assets/stylesheets/MatchTable.scss";

interface IProps {
  external_teamData:any[];
  external_matchData:any[];
}

interface IState {}

export default class MatchControl extends Component<IProps, IState> {

  constructor(props:any) {
    super(props);

    this.state = {}
  }

  getTable() {
    const content:any[] = [];

    for (var i = 0; i < 100; i++) {
      content.push(
        <tr key={i}>
          <td>A</td>
          <td>B</td>
          <td>C</td>
          <td>D</td>
          <td>E</td>
        </tr>
      )
    }

    return content;
  }

  render() {
    return (
      <div className="match-control">
        <div className="match-control-row">
          <div className="match-control-controls">
            <h1>Placeholder</h1>
          </div>

          <div className="match-control-matches">
            <table className="mt-table">
              <tbody>{this.getTable()}</tbody>
            </table>
          </div>
        </div>
      </div>
    );
  }
}