import { CJMS_POST_TEAM_UPDATE, CJMS_REQUEST_EVENT, ScoresheetModal } from "@cjms_interfaces/shared";
import { comm_service, IEvent, initIEvent, initITeamScore, ITeam, ITeamScore } from "@cjms_shared/services";
import styled from "@emotion/styled";
import { Padding, Score } from "@mui/icons-material";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import UpdateIcon from "@mui/icons-material/Update";
import ExpandMoreIcon from "@mui/icons-material/ExpandMoreOutlined";
import AddIcon from "@mui/icons-material/Add";
import { Accordion, AccordionDetails, AccordionSummary, Button, MenuItem, OutlinedInput, Select, TextField, Typography } from "@mui/material";
import { Component } from "react";

import "../../../../assets/TeamEdit.scss";

const ValidationTextField = styled(TextField)({
  '& input:valid + fieldset': {
    borderColor: 'white',
    borderWidth: 1,
  },
  '& input:invalid + fieldset': {
    borderColor: 'red',
    borderWidth: 1,
  },
  '& input:valid:focus + fieldset': {
    borderLeftWidth: 6,
    padding: '4px !important', // override inline-style
  },
});

interface ScoresheetEdit {
  scoresheet:ITeamScore;
  scoring_modal:boolean;
  existing_scores:boolean;
  scoresheet_index:number;
}

interface IProps {
  selected_team:ITeam;
}

interface IState {
  accordion_expanded:number;
  team_number:string;
  team_name:string;
  team_id:string;
  team_aff:string;
  team_ranking:number;

  scoresheet_modal:ScoresheetEdit;
  external_eventData:IEvent;

  selected_round:number;
}

export default class TeamEditValues extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      accordion_expanded: -2,

      team_number: '',
      team_name: '',
      team_id: '',
      team_aff: '',
      team_ranking: 0,

      scoresheet_modal: {scoresheet: initITeamScore(), scoring_modal: false, existing_scores: true, scoresheet_index: 0},
      external_eventData:initIEvent(),
      selected_round: 1
    }

    comm_service.listeners.onEventUpdate(() => {
      CJMS_REQUEST_EVENT().then((event) => {
        this.setEventData(event);
      });
    });

    this.closeCallback = this.closeCallback.bind(this);
  }

  handleRoundSelect(round:number) {
    this.setState({selected_round: round});
  }

  handleAccordionChange(panel:number) {
    if (this.state.accordion_expanded === panel) {
      this.setState({accordion_expanded:-2});
    } else {
      this.setState({accordion_expanded:panel});
    }
  }

  setEventData(event:IEvent) {
    this.setState({external_eventData: event});
  }

  handleTeamNumberChange(team_number:string) { this.setState({team_number:team_number}); }
  handleTeamNameChange(team_name:string) { this.setState({team_name:team_name}); }
  handleIDChange(id:string) { this.setState({team_id:id}); }
  handleAffiliationChange(aff:string) { this.setState({team_aff:aff}); }
  handleRankingChange(rank:number) { this.setState({team_ranking:rank}); }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any) {
    if (this.props != prevProps) {
      this.handleTeamNumberChange(this.props.selected_team.team_number);
      this.handleTeamNameChange(this.props.selected_team.team_name);
      this.handleIDChange(this.props.selected_team.team_id);
      this.handleAffiliationChange(this.props.selected_team.affiliation);
      this.handleRankingChange(this.props.selected_team.ranking);
    }
  }

  componentDidMount() {
    CJMS_REQUEST_EVENT().then((event) => {
      if (event) {
        this.setEventData(event);
        this.handleTeamNumberChange(this.props.selected_team.team_number);
        this.handleTeamNameChange(this.props.selected_team.team_name);
        this.handleIDChange(this.props.selected_team.team_id);
        this.handleAffiliationChange(this.props.selected_team.affiliation);
        this.handleRankingChange(this.props.selected_team.ranking);
      }
    });
  }

  handleTeamUpdate() {
    var changed_team:ITeam = Object.create(this.props.selected_team);
    changed_team.team_number = this.state.team_number;
    changed_team.team_name = this.state.team_name;
    changed_team.team_id = this.state.team_id;
    changed_team.affiliation = this.state.team_aff;
    changed_team.ranking = this.state.team_ranking;
    CJMS_POST_TEAM_UPDATE(this.props.selected_team.team_number, changed_team);
  }

  toggleModal(scoresheet:ITeamScore, scoresheet_index:number) {
    if (this.state.scoresheet_modal.scoring_modal) {
      this.setState({scoresheet_modal: {scoresheet: scoresheet, scoring_modal: false, existing_scores: true, scoresheet_index: scoresheet_index}});
    } else {
      this.setState({scoresheet_modal: {scoresheet: scoresheet, scoring_modal: true, existing_scores: true, scoresheet_index: scoresheet_index}});
    }
  }

  closeCallback() {
    var modal = this.state.scoresheet_modal;
    modal.scoring_modal = false;
    this.setState({scoresheet_modal: modal});
  }

  handleDeleteScore(index:number) {
    var team_update = this.props.selected_team;
    if (index > -1) {
      team_update.scores.splice(index, 1);
    }

    CJMS_POST_TEAM_UPDATE(this.props.selected_team.team_number, team_update);
  }

  handleAddScoresheet() {
    var scoresheet:ITeamScore = initITeamScore();
    scoresheet.scoresheet.round = this.state.selected_round;
    this.setState({
      scoresheet_modal: {
        scoresheet: scoresheet, 
        scoring_modal: true, 
        existing_scores: false, 
        scoresheet_index: 0
      }
    });
  }

  getMenuItems() {
    const content:any[] = [];
    for (var i = 0; i < this.state.external_eventData.event_rounds; i++) {
      content.push(<MenuItem key={`Round ${i+1}`} value={i+1}>Round {i+1}</MenuItem>)
    }

    return content;
  }

  render() {
    return (
      <div className="team-values">
        <Accordion sx={{backgroundColor: '#03061d', color: 'white'}} expanded={this.state.accordion_expanded === -1} onChange={() => this.handleAccordionChange(-1)}>
          <AccordionSummary expandIcon={<ExpandMoreIcon color="warning"/>}>
            <Typography>
              General Settings
            </Typography>
          </AccordionSummary>

          <AccordionDetails>
            <div className="team-values-tf">
              <ValidationTextField
                label="Team Number"
                sx={{input: {color: 'white'}, label: {color: 'white'}, marginBottom: 2}}
                value={this.state.team_number}
                onChange={(value) => this.handleTeamNumberChange(value.target.value)}
                maxRows={4}
              />

              <ValidationTextField
                label="Team Name"
                sx={{input: {color: 'white'}, label: {color: 'white'}, marginBottom: 2}}
                value={this.state.team_name}
                onChange={(value) => this.handleTeamNameChange(value.target.value)}
                maxRows={4}
              />

              <ValidationTextField
                label="ID"
                sx={{input: {color: 'white'}, label: {color: 'white'}, marginBottom: 2}}
                value={this.state.team_id}
                onChange={(value) => this.handleIDChange(value.target.value)}
                maxRows={4}
              />

              <ValidationTextField
                label="Affiliation"
                sx={{input: {color: 'white'}, label: {color: 'white'}, marginBottom: 2}}
                value={this.state.team_aff}
                onChange={(value) => this.handleAffiliationChange(value.target.value)}
                maxRows={4}
              />

              <ValidationTextField
                label="Ranking"
                sx={{input: {color: 'white'}, label: {color: 'white'}, marginBottom: 2}}
                value={this.state.team_ranking}
                onChange={(value) => this.handleRankingChange(Number(value.target.value))}
                type="number"
                maxRows={4}
              />

              <Button onClick={() => this.handleTeamUpdate()} startIcon={<UpdateIcon/>} variant="outlined" sx={{borderColor: 'green', color: 'green'}}>Update</Button>
            </div>
          </AccordionDetails>
        </Accordion>

        <>
          {this.props.selected_team.scores
            .map((round, i) => (
              <Accordion key={i} sx={{backgroundColor: '#03061d', color: 'white'}} expanded={this.state.accordion_expanded === i} onChange={() => this.handleAccordionChange(i)}>
                <AccordionSummary expandIcon={<ExpandMoreIcon color="warning"/>}>
                  <Typography>Round {round.scoresheet.round}</Typography>
                </AccordionSummary>

                <AccordionDetails>
                  <div className="team-values-text">
                    <Typography>GP: <span>{round.gp}</span></Typography>
                    <Typography>Referee: {round.referee}</Typography>
                    <Typography>Attendance: {round.no_show ? <span style={{color: 'orange', borderStyle: 'solid', borderColor: 'orange', padding: '2px'}}>No Show</span> : 'Showed'}</Typography>
                    <Typography>Score: <span style={{color: 'green'}}>{round.score}</span></Typography>
                    <Typography>
                      Scoresheet: {round.valid_scoresheet ? <span style={{color: 'green'}}>Valid</span> : <span style={{color: 'red', borderStyle: 'solid', borderColor: 'red', padding: '2px'}}>Invalid</span>}
                    </Typography>
                    {round.scoresheet.public_comment ? <Typography>Public Comment: {round.scoresheet.public_comment}</Typography> : ''}
                    {round.scoresheet.private_comment ? <Typography>Private Comment: {round.scoresheet.private_comment}</Typography> : ''}

                    <div>
                      <Button onClick={() => this.toggleModal(round, i)} startIcon={<EditIcon/>} variant="outlined" sx={{
                        marginTop: '3%',
                        marginRight: '10%',
                        width: '45%'
                      }}>Edit</Button>

                      <Button onClick={() => this.handleDeleteScore(i)} startIcon={<DeleteIcon />} variant="outlined" sx={{
                        borderColor: 'red',
                        color: 'red',
                        marginTop: '3%',
                        width: '45%'
                      }}>Delete</Button>
                    </div>

                  </div>
                </AccordionDetails>
              </Accordion>
            ))
          }
        </>


        <Accordion sx={{backgroundColor: '#03061d', color: 'white'}} expanded={this.state.accordion_expanded === this.props.selected_team.scores.length+1} onChange={() => this.handleAccordionChange(this.props.selected_team.scores.length+1)}>
          <AccordionSummary expandIcon={<ExpandMoreIcon color="warning"/>}>
            <AddIcon color="success"/>
          </AccordionSummary>

          <AccordionDetails>
            <Select
              sx={{backgroundColor: 'white', width: '30%'}}
              labelId="Round Select"
              value={this.state.selected_round}
              label="Select Round..."
              onChange={(e) => {this.handleRoundSelect(Number(e.target.value))}}
            >
              {this.getMenuItems()}
            </Select>
            <Button 
              variant="outlined"
              endIcon={<AddIcon/>}
              sx={{
                borderColor: 'green',
                color: 'green',
                marginLeft: '5%',
                paddingTop: '1%',
                paddingBottom: '1%'
              }}
              onClick={() => {this.handleAddScoresheet()}}
            >Add</Button>
          </AccordionDetails>
        </Accordion>
        
        <ScoresheetModal 
          display={this.state.scoresheet_modal.scoring_modal} 
          scoresheet={this.state.scoresheet_modal.scoresheet} 
          existing_scoresheet={this.state.scoresheet_modal.existing_scores}
          team={this.props.selected_team}
          scoresheet_index={this.state.scoresheet_modal.scoresheet_index}

          closeCallback={this.closeCallback}
        />
      </div>
    );
  }
}