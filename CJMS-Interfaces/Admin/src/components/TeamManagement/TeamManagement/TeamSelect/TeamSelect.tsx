import { initITeam, ITeam } from "@cjms_shared/services";
import { Button } from "@mui/material";
import SelectIcon from "@mui/icons-material/SelectAll";
import { Component } from "react";

import "../../../../assets/TeamSelectTable.scss";

interface IProps {
  external_teamData:ITeam[];
  setSelectedTeam:Function;
}

interface IState {
  selected_team:string;
}

export default class TeamSelect extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      selected_team: ''
    }
  }

  getTableHeaders() {
    return (
      <tr>
        <th>Ranking</th>
        <th>Team Number</th>
        <th>Team Name</th>
      </tr>
    );
  }

  handleSelectedTeam(team:string) {
    this.setState({selected_team: team});
    this.props.setSelectedTeam(team);
  }

  getTableContent() {
    return (
      this.props.external_teamData.map((t) => (
        <tr 
          key={t.team_number} 
          id={t.team_number}
          onClick={() => this.handleSelectedTeam(t.team_number)}
          className={`${t.team_number === this.state.selected_team ? 'selected' : ''}`}
        >
          <td>{t.ranking}</td>
          <td>{t.team_number}</td>
          <td>{t.team_name}</td>
        </tr>
      ))
    );
  }

  getTable() {
    return (
      <table className="tm-table">
        <thead>{this.getTableHeaders()}</thead>
        <tbody>{this.getTableContent()}</tbody>
      </table>
    );
  }


  render() {
    return(
      this.getTable()
    );
  }
}