import { IEvent, IMatch, initIMatch, ITeam } from "@cjms_shared/services";
import { Button } from "@mui/material";
import { Component } from "react";
import Select from "react-select";
import AddIcon from "@mui/icons-material/Add";
import ClearIcon from "@mui/icons-material/Clear";

import "../../assets/stylesheets/MatchBuilder.scss";
import { CJMS_POST_MATCH_CREATE } from "@cjms_interfaces/shared";

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
  options_matches: ISelectOption[];
  selected_match: IMatch;

  selected_on_table1:ISelectOption;
  selected_on_table2:ISelectOption;

  selected_table_on_table1:ISelectOption;
  selected_table_on_table2:ISelectOption;
}

export default class MatchBuilder extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      options_matches: [],
      selected_match: initIMatch(),

      selected_on_table1: {value: '', label: ''},
      selected_on_table2: {value: '', label: ''},

      selected_table_on_table1: {value: '', label: ''},
      selected_table_on_table2: {value: '', label: ''},
    }
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

  componentDidMount(): void {
    this.setInternalData();
  }

  setSelectedMatch(selected_match:ISelectOption) {
    const match = this.props.external_matchData.find((match) => match.match_number === selected_match.value) || initIMatch();
    this.setState({selected_match: match});
    this.setSelectedTeam1({value: '', label: 'NO TEAM'});
    this.setSelectedTeam2({value: '', label: 'NO TEAM'});
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

  submitCreateMatch() {
    if (confirm("Create match?")) {
      if (this.getNewMatchNumber() != undefined) {
        const match = initIMatch();
        match.match_number = this.getNewMatchNumber() || '';
        match.on_table1.team_number = this.state.selected_on_table1.value;
        match.on_table2.team_number = this.state.selected_on_table2.value;
        match.custom_match = true;
        console.log(match);
        CJMS_POST_MATCH_CREATE(match).then(() => {
          window.location.reload();
        });
      }
    }
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

  getNewMatchNumber() {
    const origin_number = this.state.selected_match.match_number;
    const origin_index = this.props.external_matchData.indexOf(this.state.selected_match);
    if (origin_index > -1) {
      var sub_index = 1;

      for (var i = origin_index+1; i < this.props.external_matchData.length; i++) {
        if (this.props.external_matchData[i].custom_match) {
          sub_index++;
        } else {
          break;
        }
      }
  
      return `${origin_number}-${sub_index}`;
    }
  }

  render() {
    const table_options:ISelectOption[] = [{value: '', label: 'NO TABLE'}];
    const team_options:ISelectOption[] = [{value: '', label: 'NO TEAM'}];
    return (
      <>
        <div className="match-builder">
          <h1>Select Match</h1>
          <div className="selector">
            <Select
              onChange={(e:any) => {this.setSelectedMatch(e)}}
              options={this.state.options_matches}
            />
          </div>

          <div className="row-editor">
            <h1>Match to Insert</h1>
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

          </div>
          <h4><span style={{color: 'green'}}>{this.getNewMatchNumber() != undefined ? `${this.getNewMatchNumber()} => {${this.state.selected_on_table1.label}, ${this.state.selected_on_table1.label}}, {${this.state.selected_on_table2.label}, ${this.state.selected_table_on_table2.label}}` : ''}</span></h4>
        </div>

        {/* Buttons */}
        <div className="match-modify submit">
          <div className="row-editor">
            <div className="submit-buttons">
              {this.state.selected_match.match_number.length > 0 ? this.createMatchButton() : ''}
            </div>

            <div className="submit-buttons">
              {this.state.selected_match.match_number.length > 0 ? this.clearButton() : ''}
            </div>
          </div>
        </div>
      </>
    );
  }
}