import { CJMS_POST_TEAM_UPDATE } from "@cjms_interfaces/shared";
import { ITeam } from "@cjms_shared/services";
import styled from "@emotion/styled";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import UpdateIcon from "@mui/icons-material/Update";
import { Accordion, AccordionDetails, AccordionSummary, Button, OutlinedInput, TextField, Typography } from "@mui/material";
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

interface IProps {
  selected_team:ITeam;
}

interface IState {
  changed_team:ITeam;
  accordion_expanded:number;
  team_number:string;
  team_name:string;
  team_id:string;
  team_aff:string;
  team_ranking:number;
}

export default class TeamValues extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      changed_team: this.props.selected_team,
      accordion_expanded: 0,

      team_number: this.props.selected_team.team_number,
      team_name: this.props.selected_team.team_name,
      team_id: this.props.selected_team.team_id,
      team_aff: this.props.selected_team.affiliation,
      team_ranking: this.props.selected_team.ranking
    }
  }

  handleAccordionChange(panel:number) {
    if (this.state.accordion_expanded === panel) {
      this.setState({accordion_expanded:-1});
    } else {
      this.setState({accordion_expanded:panel});
    }
  }

  handleTeamNumberChange(team_number:string) { this.setState({team_number:team_number}); }
  handleTeamNameChange(team_name:string) { this.setState({team_name:team_name}); }
  handleIDChange(id:string) { this.setState({team_id:id}); }
  handleAffiliationChange(aff:string) { this.setState({team_aff:aff}); }
  handleRankingChange(rank:number) { this.setState({team_ranking:rank}); }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any) {
    if (this.props != prevProps) {
      this.setState({changed_team: this.props.selected_team});
      this.handleTeamNumberChange(this.props.selected_team.team_number);
      this.handleTeamNameChange(this.props.selected_team.team_name);
      this.handleIDChange(this.props.selected_team.team_id);
      this.handleAffiliationChange(this.props.selected_team.affiliation);
      this.handleRankingChange(this.props.selected_team.ranking);
    }
  }

  handleTeamUpdate() {
    this.state.changed_team.team_number = this.state.team_number;
    this.state.changed_team.team_name = this.state.team_name;
    this.state.changed_team.team_id = this.state.team_id;
    this.state.changed_team.affiliation = this.state.team_aff;
    this.state.changed_team.ranking = this.state.team_ranking;
    CJMS_POST_TEAM_UPDATE(this.props.selected_team.team_number, this.state.changed_team);
  }

  render() {
    return (
      <div className="team-values">
          <Accordion sx={{backgroundColor: '#03061d', color: 'white'}} expanded={this.state.accordion_expanded === 0} onChange={() => this.handleAccordionChange(0)}>
            <AccordionSummary>
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
              <Accordion key={i} sx={{backgroundColor: '#03061d', color: 'white'}} expanded={this.state.accordion_expanded === i+1} onChange={() => this.handleAccordionChange(i+1)}>
                <AccordionSummary>
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

                    <div>
                      <Button startIcon={<EditIcon/>} variant="outlined" sx={{
                        marginTop: '3%',
                        marginRight: '10%',
                        width: '45%'
                      }}>Edit</Button>

                      <Button startIcon={<DeleteIcon />} variant="outlined" sx={{
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
      </div>
    );
  }
}