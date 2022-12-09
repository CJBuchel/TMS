import { comm_service, IEvent, IMatch, initIMatch, initITeam, ITeam, request_namespaces } from "@cjms_shared/services";
import { CJMS_FETCH_GENERIC_GET, CJMS_FETCH_GENERIC_POST, CJMS_POST_MATCH_CREATE, CJMS_POST_MATCH_DELETE, CJMS_POST_MATCH_UPDATE } from "@cjms_interfaces/shared";
import { Button, FormControl, FormControlLabel, FormLabel, Radio, RadioGroup } from "@mui/material";
import { Component } from "react";
import UpdateIcon from "@mui/icons-material/Update";
import AddIcon from "@mui/icons-material/Add";
import ClearIcon from "@mui/icons-material/Clear";
import DeleteIcon from "@mui/icons-material/Delete";
import Select from "react-select";

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
  selected_match_number:string;

  selected_on_table1:ISelectOption;
  selected_on_table2:ISelectOption;

  selected_table_on_table1:ISelectOption;
  selected_table_on_table2:ISelectOption;

  selected_start_time:string;

  loaded_match:string;
}

export default class MatchEdit extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {
      options_matches: [],
      selected_match: initIMatch(),
      selected_match_number: '',

      selected_on_table1: {value: '', label: ''},
      selected_on_table2: {value: '', label: ''},

      selected_table_on_table1: {value: '', label: ''},
      selected_table_on_table2: {value: '', label: ''},

      selected_start_time: '00:00',

      loaded_match: ''
    }

    comm_service.listeners.onMatchLoaded((match:string) => {
      this.setState({loaded_match:match});
    });

    this.setSelectedMatch = this.setSelectedMatch.bind(this);
  }

  setInternalData() {
    if (this.props.external_matchData.length > 0 && this.props.external_teamData.length > 0) {
      const matchOptions:ISelectOption[] = [];
      this.props.external_matchData.map((match) => {
        const team1 = this.props.external_teamData.find((team) => team.team_number === match.on_table1.team_number);
        const team2 = this.props.external_teamData.find((team) => team.team_number === match.on_table2.team_number);
        var team1String = team1 ? `${team1?.team_number} | ${team1?.team_name}` : '';
        var team2String = team2 ? `${team2?.team_number} | ${team2?.team_name}` : '';
        matchOptions.push({
          value: match.match_number, 
          label: `#${match.match_number} => {${team1String}}, {${team2String}}`
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

  submitUpdateMatch() {
    if (confirm("Update match?")) {
      const match = this.state.selected_match;
      match.on_table1.team_number = this.state.selected_on_table1.value;
      match.on_table1.table = this.state.selected_table_on_table1.value;
      match.on_table2.team_number = this.state.selected_on_table2.value;
      match.on_table2.table = this.state.selected_table_on_table2.value;
      if (Number(this.state.selected_start_time.slice(0,2)) >= 12) {
        match.start_time = `${this.state.selected_start_time}:00 PM`;
      } else {
        match.start_time = `${this.state.selected_start_time}:00 AM`;
      }
      // console.log(match);
      CJMS_POST_MATCH_UPDATE(match.match_number, match).then(() => {
        window.location.reload();
      });
    }
  }

  submitCreateMatch() {
    if (confirm("Create match?")) {
      const match = initIMatch();
      match.match_number = `${this.state.selected_match_number}`;
      match.on_table1.team_number = this.state.selected_on_table1.value;
      match.on_table1.table = this.state.selected_table_on_table1.value;
      match.on_table2.team_number = this.state.selected_on_table2.value;
      match.on_table2.table = this.state.selected_table_on_table2.value;

      if (Number(this.state.selected_start_time.slice(0,2)) >= 12) {
        match.start_time = `${this.state.selected_start_time}:00 PM`;
      } else {
        match.start_time = `${this.state.selected_start_time}:00 AM`;
      }

      CJMS_POST_MATCH_CREATE(match).then(() => {
        window.location.reload();
      });
    }
  }

  submitDeleteMatch() {
    if (confirm(`Delete match ${this.state.selected_match.match_number}?`)) {
      console.log(`${this.state.selected_match.match_number} ${this.state.loaded_match}`);
      if (this.state.selected_match.match_number === this.state.loaded_match) {
        CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_load, {load:false, match: ''}).then(() => {
          CJMS_POST_MATCH_DELETE(this.state.selected_match.match_number).then(() => {
            window.location.reload();
          });
        })
      } else {
        CJMS_POST_MATCH_DELETE(this.state.selected_match.match_number).then(() => {
          window.location.reload();
        });
      }
    }
  }


  setSelectedMatch(selected_match:ISelectOption) {
    // console.log(selected_match);

    const match = this.props.external_matchData.find((match) => selected_match.value === match.match_number) || initIMatch();
    const team1 = this.props.external_teamData.find((team) => match.on_table1.team_number === team.team_number) || initITeam();
    const team2 = this.props.external_teamData.find((team) => match.on_table2.team_number === team.team_number) || initITeam();

    var team1String = team1.team_number.length > 0 ? `${team1?.team_number} | ${team1?.team_name}` : '';
    var team2String = team2.team_number.length > 0 ? `${team2?.team_number} | ${team2?.team_name}` : '';

    console.log(match);

    this.setState({
      selected_match: match,
      selected_on_table1: {value: team1.team_number, label: `${team1String}`},
      selected_on_table2: {value: team2.team_number, label: `${team2String}`},
      selected_table_on_table1: {value: match.on_table1.table, label: match.on_table1.table},
      selected_table_on_table2: {value: match.on_table2.table, label: match.on_table2.table},
      selected_start_time: match.start_time.slice(0,5)
    });
  }

  setSelectedTeam1(team:ISelectOption) {
    this.setState({selected_on_table1: team});
    if (team.value === '') {
      this.setState({selected_table_on_table1: {value: '', label: 'NO TABLE'}});
    }
  }

  setSelectedTableTeam1(table:ISelectOption) {
    this.setState({selected_table_on_table1: table});
  }

  setSelectedTeam2(team:ISelectOption) {
    this.setState({selected_on_table2: team});
    if (team.value === '') {
      this.setState({selected_table_on_table2: {value: '', label: 'NO TABLE'}});
    }
  }

  setSelectedTableTeam2(table:ISelectOption) {
    this.setState({selected_table_on_table2: table});
  }

  setTeam1Submitted(submitted:boolean) {
    const match = this.state.selected_match;
    match.on_table1.score_submitted = submitted;
    this.setState({selected_match: match});
  }

  setTeam2Submitted(submitted:boolean) {
    const match = this.state.selected_match;
    match.on_table2.score_submitted = submitted;
    this.setState({selected_match: match});
  }

  updateMatchButton() {
    return (
      <Button
        variant="contained"
        color="primary"
        endIcon={<UpdateIcon/>}
        onClick={() => this.submitUpdateMatch()}
        sx={{
          width: '100%',
          height: '100%',
          fontSize: '3vh'
        }}
      >Update Match</Button>
    )
  }

  createMatchButton() {
    return (
      <Button
        variant="contained"
        color="success"
        endIcon={<AddIcon/>}
        onClick={() => this.submitCreateMatch()}
        sx={{
          width: '100%',
          height: '100%',
          fontSize: '3vh'
        }}
      >Create Match</Button>
    )
  }

  clearButton() {
    return (
      <Button
        variant="contained"
        color="warning"
        endIcon={<ClearIcon/>}
        onClick={() => window.location.reload()}
        sx={{
          width: '100%',
          height: '100%',
          fontSize: '3vh'
        }}
      >Reset</Button>
    )
  }

  deleteMatchButton() {
    return (
      <Button
        variant="contained"
        color="error"
        endIcon={<DeleteIcon/>}
        onClick={() => this.submitDeleteMatch()}
        sx={{
          width: '100%',
          height: '100%',
          fontSize: '3vh'
        }}
      >Delete Match</Button>
    )
  }

  getMatchNumberInput() {
    if (this.state.selected_match.match_number.length <= 0) {
      return (
        <div className="column-editor toggles">
          <h3 style={{color: 'white'}}>Match Number e.g 21-1</h3>
          <input name="match_number" onChange={(e) => this.setState({selected_match_number:e.target.value})}/>
        </div>
      )
    }
  }
  
  render() {
    const table_options:ISelectOption[] = [{value: '', label: 'NO TABLE'}];
    const team_options:ISelectOption[] = [{value: '', label: 'NO TEAM'}];
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
                options={team_options.concat(this.props.external_teamData.map((team) => ({value: team.team_number, label: `${team.team_number} | ${team.team_name}`})))}
              />
            </div>

            <div className="column-editor">
              <Select 
                onChange={(e:any) => this.setSelectedTableTeam1(e)} 
                value={this.state.selected_table_on_table1} 
                options={table_options.concat(this.props.external_eventData.event_tables.map((table) => ({value: table, label: table})))}
              />
            </div>
            
            <div className="column-editor">
              <Select 
                onChange={(e:any) => this.setSelectedTeam2(e)} 
                value={this.state.selected_on_table2} 
                options={team_options.concat(this.props.external_teamData.map((team) => ({value: team.team_number, label: `${team.team_number} | ${team.team_name}`})))}
              />
            </div>

            <div className="column-editor">
              <Select 
                onChange={(e:any) => this.setSelectedTableTeam2(e)} 
                value={this.state.selected_table_on_table2} 
                options={table_options.concat(this.props.external_eventData.event_tables.map((table) => ({value: table, label: table})))}
              />
            </div>

            {/* team 1 */}
            <div className="column-editor toggles">
              <FormControl sx={{color: 'white'}}>
                <FormLabel sx={{color: 'white'}}>Submitted</FormLabel>
                <RadioGroup
                  value={this.state.selected_match.on_table1.score_submitted}
                  onChange={(e) => this.setTeam1Submitted(e.target.value === 'true' ? true : false)}
                >
                  <FormControlLabel value={true} control={<Radio color='success' sx={{color: 'white'}}/>} label="true" />
                  <FormControlLabel value={false} control={<Radio color='error' sx={{color: 'white'}}/>} label="false" />
                </RadioGroup>
              </FormControl>
            </div>

            {/* team 2 */}
            <div className="column-editor toggles">
              <FormControl sx={{color: 'white'}}>
                <FormLabel sx={{color: 'white'}}>Submitted</FormLabel>
                <RadioGroup
                  value={this.state.selected_match.on_table2.score_submitted}
                  onChange={(e) => this.setTeam2Submitted(e.target.value === 'true' ? true : false)}
                >
                  <FormControlLabel value={true} control={<Radio color='success' sx={{color: 'white'}}/>} label="true" />
                  <FormControlLabel value={false} control={<Radio color='error' sx={{color: 'white'}}/>} label="false" />
                </RadioGroup>
              </FormControl>
            </div>

            <div className="column-editor toggles">
              <h3 style={{color: 'white'}}>Start Time</h3>
              <input type='time' name="time" value={this.state.selected_start_time} onChange={(e) => this.setState({selected_start_time:e.target.value})}/>
            </div>

            {this.getMatchNumberInput()}
          </div>
        </div>

        {/* Buttons */}
        <div className="match-modify submit">
          <div className="row-editor">
            <div className="submit-buttons">
              {this.state.selected_match.match_number.length > 0 ? this.updateMatchButton() : this.createMatchButton()}
            </div>

            <div className="submit-buttons">
              {this.state.selected_match.match_number.length > 0 ? this.clearButton() : this.clearButton()}
            </div>

            <div className="delete-button">
              {this.state.selected_match.match_number.length > 0 ? this.deleteMatchButton() : ''}
            </div>
          </div>
        </div>
      </>
    );
  }
}