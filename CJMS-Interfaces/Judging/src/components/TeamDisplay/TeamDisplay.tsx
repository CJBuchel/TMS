import { IEvent, IMatch, ITeam } from "@cjms_shared/services";
import { Component } from "react";
import { TeamTable } from "../TeamTable";

import { Button } from "@mui/material";

import "../../assets/stylesheets/TeamDisplay.scss";
import "../../assets/stylesheets/TeamTable.scss";
import Export from "./Export";

interface IProps {
  external_eventData:IEvent;
  external_matchData:IMatch[];
  external_teamData:ITeam[];
}

interface IState {}

export default class TeamDisplay extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  handleExport(comments:boolean = false) {
    const export_teams = new Export(this.props.external_teamData, this.props.external_eventData.event_rounds);
    export_teams.exportCSV(comments);
  }

  render() {
    return(
      <div className="team-display">
        <div className="export-buttons">
          <Button
            variant="contained"
            onClick={() => this.handleExport()}
            sx={{
              margin: '0px 25px',
              backgroundColor: 'teal'
            }}
          >Export</Button>
          <Button
            variant="contained"
            onClick={() => this.handleExport(true)}
            sx={{
              margin: '0px 25px',
              backgroundColor: 'teal'
            }}
          >Export w/Comments</Button>
        </div>
        <div className="table-wrapper">
          <TeamTable
            external_eventData={this.props.external_eventData}
            external_teamData={this.props.external_teamData}
            external_matchData={this.props.external_matchData}
          />
        </div>
      </div>
    );
  }
}