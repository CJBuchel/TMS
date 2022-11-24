import { IEvent, IMatch, initIMatch, ITeam } from "@cjms_shared/services";
import React, { Component } from "react";

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
    var table_scores:{score:string, gp:string}[] = [];
    for (var i = 0; i < this.props.external_eventData.event_rounds; i++) {
      if (team.scores[i]) {
        table_scores.push({score:team.scores[i].score.toString(), gp:team.scores[i].gp});
      } else {
        table_scores.push({score:'', gp:''});
      }
    }

    if (this.props.external_matchData.length > 0) {
      const team_matches = this.props.external_matchData.filter(match => match.on_table1.team_number === team.team_number || match.on_table2.team_number === team.team_number);
      team_matches.sort((a:any,b:any) => {return a.match_number-b.match_number});
      return (
        table_scores.map((score,i) => {
          if (team_matches[i] != undefined && team_matches[i] != null) {
            var onTable = initIMatch().on_table1;
            if (team_matches[i]?.on_table1 != undefined && team_matches[i]?.on_table1?.team_number === team.team_number) {
              onTable = team_matches[i]?.on_table1;
            } else if (team_matches[i]?.on_table2 != undefined && team_matches[i]?.on_table2?.team_number === team.team_number) {
              onTable = team_matches[i]?.on_table2;
            }
            // const onTable = (team_matches[i]?.on_table1 != undefined && team_matches[i]?.on_table1?.team_number === team.team_number) ? team_matches[i].on_table1 : team_matches[i].on_table2;
            return (
              <React.Fragment key={i}>
                <td
                  style={{
                    backgroundColor : `${
                      team_matches[i].deferred ? 'cyan' :
                      team_matches[i].complete && !onTable.score_submitted ? 'red' : 
                      team_matches[i].complete && onTable.score_submitted ? 'green' : ''
                    }`
                  }}
                >{`${score.score}`}</td>
                <td
                  style={{
                    backgroundColor : `${
                      team_matches[i].deferred ? 'cyan' :
                      team_matches[i].complete && !onTable.score_submitted ? 'red' : 
                      team_matches[i].complete && onTable.score_submitted ? 'green' : ''
                    }`
                  }}
                >{`${score.gp}`}</td>
              </React.Fragment>
            )
          } else {
            console.log("Null information")
          }
        })
      );
    }
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