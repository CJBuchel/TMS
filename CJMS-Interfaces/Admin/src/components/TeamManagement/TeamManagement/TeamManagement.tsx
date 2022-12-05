import { CJMS_REQUEST_TEAMS } from "@cjms_interfaces/shared";
import { comm_service, initITeam, ITeam } from "@cjms_shared/services";
import { Component } from "react";

import { TeamSelect } from "./TeamSelect";

import "../../../assets/TeamManagement.scss";
import { TeamEdit } from "./TeamEdit";

interface IProps {}

interface IState {
  teamData:ITeam[];
  selected_team:ITeam;
  selected_team_number:string;
}

export default class TeamManagement extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      teamData: [],
      selected_team: initITeam(),
      selected_team_number: ''
    }

    comm_service.listeners.onTeamUpdate(async () => {
      const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
      this.setTeamData(teamData);
    });

    this.setSelectedTeam = this.setSelectedTeam.bind(this);
  }

  setTeamData(teams:ITeam[]) {

    // Sort teams by number instead of rank (better for admin)
    teams.sort(function(a,b){
      return a.team_number.localeCompare(b.team_number, undefined, {
        numeric: true,
        sensitivity: 'base'
      });
    });

    this.setState({teamData: teams});
    if (this.state.selected_team_number.length > 0) {
      this.setSelectedTeam(this.state.selected_team_number);
    }
  }

  setSelectedTeam(team:string) {
    this.setState({selected_team_number: team});
    var sel_team:ITeam = this.state.teamData.find(t => t.team_number === team) || initITeam();
    sel_team.scores.sort(function(a, b){return a.scoresheet.round-b.scoresheet.round});
    this.setState({selected_team: sel_team});
  }

  async componentDidMount() {
    const teamData:ITeam[] = await CJMS_REQUEST_TEAMS(true);
    this.setTeamData(teamData);

    console.log(teamData[0].createdAt);
  }

  render() {
    if (this.state.teamData) {
      return (
        <div className="team-management">
          <div className="tm-row">
            <div className="tm-team-select">
              <TeamSelect external_teamData={this.state.teamData} setSelectedTeam={this.setSelectedTeam}/>
            </div>
  
            <div className="tm-team-manage">
              <TeamEdit selected_team={this.state.selected_team}/>
            </div>
          </div>
        </div>
      );
    } else {
      return(<></>);
    }
  }
}