import { ITeam, ITeamScore } from "@cjms_shared/services";
import { Button, Grid, Typography } from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import { Component } from "react";

interface IScoresheet {
  scoresheet:ITeamScore;
  team_number:string;
}

interface IProps {
  scoresheet:IScoresheet;
  team:ITeam;
}

interface IState {}

export default class ScoreContainer extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  render() {
    var scoresheet = this.props.scoresheet.scoresheet;
    return(
      <Grid item 
        sx={{
          backgroundColor: '#03061d', 
          color: 'white',
          padding: '2% 4% 2% 4%',
          borderRadius: '20px',
          margin: '1%',
          borderStyle: 'solid',
          borderColor: 'white'
        }}
      >
        <Typography>Team: <span>{this.props.team.team_name}</span></Typography>
        <Typography>Number: <span>{this.props.team.team_number}</span></Typography>
        <Typography>GP: <span>{scoresheet.gp}</span></Typography>
        <Typography>Referee: {scoresheet.referee}</Typography>
        <Typography>Attendance: {scoresheet.no_show ? <span style={{color: 'orange', borderStyle: 'solid', borderColor: 'orange', padding: '2px'}}>No Show</span> : 'Showed'}</Typography>
        <Typography>Score: <span style={{color: 'green'}}>{scoresheet.score}</span></Typography>
        <Typography>
          Scoresheet: {scoresheet.valid_scoresheet ? <span style={{color: 'green'}}>Valid</span> : <span style={{color: 'red', borderStyle: 'solid', borderColor: 'red', padding: '2px'}}>Invalid</span>}
        </Typography>

        <div>
          <Button onClick={() => {}} startIcon={<EditIcon/>} variant="outlined" sx={{
            marginTop: '3%',
            marginRight: '10%',
            width: '45%'
          }}>Edit</Button>

          <Button onClick={() => {}} startIcon={<DeleteIcon />} variant="outlined" sx={{
            borderColor: 'red',
            color: 'red',
            marginTop: '3%',
            width: '45%'
          }}>Delete</Button>
        </div>
      </Grid>
    );
  }
}