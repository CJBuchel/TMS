import { CJMS_REQUEST_EVENT, CJMS_REQUEST_TEAMS } from "@cjms_interfaces/shared";
import { comm_service, IEvent, initIEvent, initITeam, ITeam, ITeamScore } from "@cjms_shared/services";
import { Button, Grid, MenuItem, Paper, Select, Typography } from "@mui/material";
import { borderColor, color } from "@mui/system";
import React, { Component } from "react";
import CloudPublish from "./CloudPublish";
import ScoreContainer from "./ScoreContainer";

import "../../../assets/ScoreContainer.scss";

interface IScoresheet {
  scoresheet:ITeamScore;
  team_number:string;
}

interface IProps {}

interface IState {
  external_teamData:ITeam[];
  external_eventData:IEvent;
  scoresheets:IScoresheet[];
}

export default class Scoring extends Component<IProps, IState> {
  constructor(props:any) {
    super(props)

    this.state = {
      external_eventData: initIEvent(),
      external_teamData: [],
      scoresheets: []
    }

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
      if (teamData != undefined) {
        this.setTeamData(teamData);
      }
    });

    comm_service.listeners.onEventUpdate(async () => {
      const eventData:IEvent = await CJMS_REQUEST_EVENT(true);
      if (eventData != undefined) {
        this.setEventData(eventData);
      }
      const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
      if (teamData != undefined) {
        this.setTeamData(teamData);
      }
    });
  }

  setEventData(event:IEvent) {
    this.setState({external_eventData:event});
  } 

  setTeamData(teams:ITeam[]) {
    this.setState({external_teamData: teams});

    const scores:IScoresheet[] = [];
    for (const team of teams) {
      for (const score of team.scores) {
        scores.push({scoresheet: score, team_number: team.team_number});
      }
    }

    scores.sort((a:IScoresheet, b:IScoresheet) => {
      return new Date(b.scoresheet.createdAt||0).getTime() - new Date(a.scoresheet.createdAt||0).getTime();
    });

    this.setState({scoresheets: scores});
  }

  async componentDidMount() {
    const eventData:IEvent = await CJMS_REQUEST_EVENT(true);
    if (eventData != undefined) {
      this.setEventData(eventData);
    }
    const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
    if (teamData != undefined) {
      this.setTeamData(teamData);
    }
  }

  getFilterItems() {
    return (
      <MenuItem>Filter by update timestamp</MenuItem>
    )
  }

  testConflict(scoresheet:IScoresheet) {
    const team = this.state.external_teamData.find((team) => team.team_number === scoresheet.team_number);
    if (team != undefined) {
      return team.scores.filter((sc) => sc.scoresheet.round === scoresheet.scoresheet.scoresheet.round).length > 1 ? true : false;
    } else {
      return false;
    }
  }

  render() {
    {this.state.scoresheets.map((scoresheet) => {this.testConflict(scoresheet)})}
    return(
      <React.Fragment>
        <div className="sc-grid-container">
          <CloudPublish external_eventData={this.state.external_eventData} external_teamData={this.state.external_teamData}/>
          <Grid container sx={{backgroundColor: '#18191f', borderRadius: '20px'}}>
            {this.state.scoresheets.map((scoresheet, i) => (
              <ScoreContainer 
                key={i}
                scoresheet={scoresheet}
                conflict={this.testConflict(scoresheet)}
                team={this.state.external_teamData.find((team) => team.team_number === scoresheet.team_number) || initITeam()}
              />
            ))}
          </Grid>
        </div>
      </React.Fragment>
    );
  }
}