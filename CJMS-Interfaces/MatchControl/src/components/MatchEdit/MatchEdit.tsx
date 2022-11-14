import { IEvent, IMatch, initIMatch, initITeam, ITeam } from "@cjms_shared/services";
import { Button, FormControl, FormControlLabel, FormLabel, Radio, RadioGroup } from "@mui/material";
import { Component } from "react";
import UpdateIcon from "@mui/icons-material/Update";
import AddIcon from "@mui/icons-material/Add";
import ClearIcon from "@mui/icons-material/Clear";
import DeleteIcon from "@mui/icons-material/Delete";
import Select, { SingleValue } from "react-select";

import "../../assets/stylesheets/MatchEdit.scss";

interface ISelectOption {
  value:any;
  label:string;
}

interface IProps {
  external_eventData:IEvent;
  external_teamData:ITeam[];
  external_matchData:IMatch[];
}

interface IState {
  options_matches:ISelectOption[];
  selected_match:IMatch;

  selected_on_table1:ISelectOption;
  selected_on_table2:ISelectOption;
}

export default class MatchEdit extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      options_matches: [],
      selected_match: initIMatch(),

      selected_on_table1: {value: '', label: ''},
      selected_on_table2: {value: '', label: ''}
    }

    this.setSelectedMatch = this.setSelectedMatch.bind(this);
  }

  setInternalData() {
    if (this.props.external_matchData.length > 0 && this.props.external_teamData.length > 0) {
      const matchOptions:ISelectOption[] = [];
      this.props.external_matchData.map((match) => {
        const team1 = this.props.external_teamData.find((team) => team.team_number === match.on_table1.team_number);
        const team2 = this.props.external_teamData.find((team) => team.team_number === match.on_table2.team_number);
        matchOptions.push({
          value: match.match_number, 
          label: `#${match.match_number} => {${team1?.team_number} | ${team1?.team_name}}, {${team2?.team_number} | ${team2?.team_name}}`
        });
      });

      this.setState({options_matches: matchOptions});
    }
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (this.props != prevProps) {
      this.setInternalData();
    }
  }

  componentDidMount() {
    this.setInternalData();
  }

  setSelectedMatch(selected_match:ISelectOption) {
    console.log(selected_match);

    const match = this.props.external_matchData.find((match) => selected_match.value === match.match_number) || initIMatch();
    const team1 = this.props.external_teamData.find((team) => match.on_table1.team_number === team.team_number) || initITeam();
    const team2 = this.props.external_teamData.find((team) => match.on_table2.team_number === team.team_number) || initITeam();

    this.setState({
      selected_match: match,
      selected_on_table1: {value: team1.team_number, label: `${team1.team_number} | ${team1.team_name}`},
      selected_on_table2: {value: team2.team_number, label: `${team2.team_number} | ${team2.team_name}`},
    });
  }

  setSelectedTeam1(team:ISelectOption) {
    this.setState({selected_on_table1: team});
  }

  setSelectedTeam2(team:ISelectOption) {
    this.setState({selected_on_table2: team});
  }

  updateMatchButton() {
    return (
      <Button
        variant="contained"
        color="primary"
        endIcon={<UpdateIcon/>}
      >Update Match</Button>
    )
  }

  createMatchButton() {
    return (
      <Button
        variant="contained"
        color="success"
        endIcon={<AddIcon/>}
      >Create Match</Button>
    )
  }

  clearButton() {
    return (
      <Button
        variant="contained"
        color="warning"
        endIcon={<ClearIcon/>}
      >Clear</Button>
    )
  }

  deleteMatchButton() {
    return (
      <Button
        variant="contained"
        color="error"
        endIcon={<DeleteIcon/>}
      >Delete Match</Button>
    )
  }
  
  render() {
    return (
      <>
        <div className="match-modify">
          <h1>Select Match</h1>
          <div className="selector">
            <Select onChange={(e:any) => {this.setSelectedMatch(e)}} options={this.state.options_matches}/>
          </div>

          <div className="row-editor">
            <div className="column-editor">
              <Select 
                onChange={(e:any) => this.setSelectedTeam1(e)} 
                value={this.state.selected_on_table1} 
                options={this.props.external_teamData.map((team) => ({value: team.team_number, label: `${team.team_number} | ${team.team_name}`}))}/>
            </div>
            
            <div className="column-editor">
              <Select 
                onChange={(e:any) => this.setSelectedTeam2(e)} 
                value={this.state.selected_on_table2} 
                options={this.props.external_teamData.map((team) => ({value: team.team_number, label: `${team.team_number} | ${team.team_name}`}))}/>
            </div>

            {/* team 1 */}
            <div className="column-editor toggles">
              <FormControl sx={{color: 'white'}}>
                <FormLabel sx={{color: 'white'}}>Submitted</FormLabel>
                <RadioGroup>
                  <FormControlLabel value={true} control={<Radio color='success' sx={{color: 'white'}}/>} label="true" />
                  <FormControlLabel value={false} control={<Radio color='error' sx={{color: 'white'}}/>} label="false" />
                </RadioGroup>
              </FormControl>
            </div>

            {/* team 2 */}
            <div className="column-editor toggles">
              <FormControl sx={{color: 'white'}}>
                <FormLabel sx={{color: 'white'}}>Submitted</FormLabel>
                <RadioGroup>
                  <FormControlLabel value={true} control={<Radio color='success' sx={{color: 'white'}}/>} label="true" />
                  <FormControlLabel value={false} control={<Radio color='error' sx={{color: 'white'}}/>} label="false" />
                </RadioGroup>
              </FormControl>
            </div>
          </div>
        </div>

        {/* Changed data */}
        <div className="match-modify submit">
          <div className="row-editor">
            <div className="column-editor">
              {this.state.selected_match.match_number.length > 0 ? this.updateMatchButton() : this.createMatchButton()}
            </div>

            <div className="column-editor">
              {this.state.selected_match.match_number.length > 0 ? this.deleteMatchButton() : this.clearButton()}
            </div>
          </div>
        </div>
      </>
    );
  }
}