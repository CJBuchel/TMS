import { initITeamScore, ITeam, ITeamScore } from "@cjms_shared/services";
import { Button, Grid, Typography } from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import React, { Component } from "react";
import { CJMS_POST_TEAM_UPDATE, ScoresheetModal } from "@cjms_interfaces/shared";

interface ScoresheetEdit {
  scoresheet:ITeamScore;
  scoring_modal:boolean;
  existing_scores:boolean;
  scoresheet_index:number;
}

interface IScoresheet {
  scoresheet:ITeamScore;
  team_number:string;
}

interface IProps {
  scoresheet:IScoresheet;
  team:ITeam;
  conflict:boolean;
}

interface IState {
  scoresheet_modal:ScoresheetEdit;
}

export default class ScoreContainer extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      scoresheet_modal: {scoresheet: initITeamScore(), scoring_modal: false, existing_scores: true, scoresheet_index: 0},
    }

    this.closeCallback = this.closeCallback.bind(this);
  }

  closeCallback() {
    var modal = this.state.scoresheet_modal;
    modal.scoring_modal = false;
    this.setState({scoresheet_modal: modal});
  }

  handleDelete() {
    if (confirm('Delete score?')) {
      const index = this.props.team.scores.indexOf(this.props.scoresheet.scoresheet);
      
      if (index != -1) {
        var team_update = this.props.team;
        team_update.scores.splice(index, 1);
        CJMS_POST_TEAM_UPDATE(this.props.team.team_number, team_update);
      }
    }
  }

  toggleModal() {
    const index = this.props.team.scores.indexOf(this.props.scoresheet.scoresheet);

    if (index != -1) {
      if (this.state.scoresheet_modal.scoring_modal) {
        this.setState({scoresheet_modal: {scoresheet: this.props.scoresheet.scoresheet, scoring_modal: false, existing_scores: true, scoresheet_index: index}});
      } else {
        this.setState({scoresheet_modal: {scoresheet: this.props.scoresheet.scoresheet, scoring_modal: true, existing_scores: true, scoresheet_index: index}});
      }
    }
  }

  render() {
    var scoresheet = this.props.scoresheet.scoresheet;
    return(
      <React.Fragment>
        <Grid item 
          sx={{
            backgroundColor: '#03061d', 
            color: 'white',
            padding: '2% 5.5% 2% 5.5%',
            borderRadius: '20px',
            margin: '1%',
            borderStyle: 'solid',
            borderColor: `${scoresheet.cloud_published ? 'red' : 'white'}`
          }}
        >
          <Typography>Team: <span>{this.props.team.team_name}</span></Typography>
          <Typography>Number: <span>{this.props.team.team_number}</span></Typography>
          <Typography>Round: <span>{scoresheet.scoresheet.round}</span></Typography>
          <Typography>GP: <span>{scoresheet.gp}</span></Typography>
          <Typography>Referee: {scoresheet.referee}</Typography>
          <Typography>Attendance: {scoresheet.no_show ? <span style={{color: 'orange', borderStyle: 'solid', borderColor: 'orange', padding: '2px'}}>NO SHOW</span> : 'Showed'}</Typography>
          <Typography>Score: <span style={{color: 'green'}}>{scoresheet.score}</span></Typography>
          <Typography>
            Scoresheet: {scoresheet.valid_scoresheet ? <span style={{color: 'green'}}>Valid</span> : <span style={{color: 'red', borderStyle: 'solid', borderColor: 'red', padding: '2px'}}>INVALID</span>}
          </Typography>
          <Typography>
            {this.props.conflict ? <span style={{color: 'orange', borderStyle: 'solid', borderColor: 'orange', padding: '2px'}}>CONFLICT</span> : ''}
          </Typography>
          <Typography>{scoresheet.cloud_published ? <span style={{color: 'cyan', borderStyle: 'solid', borderColor: 'red', padding: '2px'}}>Cloud Published</span> : ''}</Typography>

          <div>
            <Button onClick={() => this.toggleModal()} startIcon={<EditIcon/>} variant="outlined" sx={{
              marginTop: '3%',
              marginRight: '10%',
              width: '45%'
            }}>Edit</Button>

            <Button onClick={() => this.handleDelete()} startIcon={<DeleteIcon />} variant="outlined" sx={{
              borderColor: 'red',
              color: 'red',
              marginTop: '3%',
              width: '45%'
            }}>Delete</Button>
          </div>
        </Grid>
        <ScoresheetModal
          display={this.state.scoresheet_modal.scoring_modal} 
          scoresheet={this.state.scoresheet_modal.scoresheet} 
          existing_scoresheet={this.state.scoresheet_modal.existing_scores}
          team={this.props.team}
          scoresheet_index={this.state.scoresheet_modal.scoresheet_index}

          closeCallback={this.closeCallback}
        />
      </React.Fragment>
    );
  }
}