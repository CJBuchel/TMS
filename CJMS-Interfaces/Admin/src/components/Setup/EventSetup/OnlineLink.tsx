import React, {Component} from "react";

import { CLOUD_REQUEST_TOURNAMENTS, CLOUD_REQUEST_TEAMS, CJMS_REQUEST_TEAMS, CJMS_REQUEST_EVENT, CJMS_POST_EVENT_UPDATE, CJMS_POST_TEAM_UPDATE } from "@cjms_interfaces/shared";
import {  comm_service, IEvent, ITeam, } from "@cjms_shared/services";
import Select from "react-select";
import Games from "ausfll-score-calculator";
import { FormControlLabel, Radio, RadioGroup } from "@mui/material";
import "../../../assets/Setup.scss"

interface SelectOption {
  value:any,
  label:string
}

enum CrossCheckStyle {
  FormattedTeamNumbers = 0,
  TeamNumbers,
  TeamNames
}

interface TeamLink {
  team_number: string;
  cloud_team_id: string;
}

interface IProps {}

interface IState {
  tournament_options:SelectOption[];
  selected_tournament:string;
  tournament_token:string;
  link_style:CrossCheckStyle;
  link_errors:string[];
  matching_teams:TeamLink[];
  tournaments:any[];
  eventData?:IEvent;
}

export default class OnlineLink extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      tournament_options: [],
      selected_tournament: "",
      tournament_token: "",
      link_style: CrossCheckStyle.FormattedTeamNumbers,
      link_errors: [],
      matching_teams: [],
      tournaments: [],
      eventData: undefined
    }

    this.onLink = this.onLink.bind(this);

    comm_service.listeners.onEventUpdate(async () => {
      CJMS_REQUEST_EVENT().then((event) => {
        this.setEventData(event);
      });
    });
  }

  componentDidMount(): void {
    CLOUD_REQUEST_TOURNAMENTS().then((res:any) => {
      this.setupOptions(res);
    });

    CJMS_REQUEST_EVENT().then((event) => {
      this.setEventData(event);
    });
  }

  setEventData(eventData:IEvent) {
    this.setState({eventData: eventData});
  }

  setSelectedTournament(value:string) {
    this.setState({selected_tournament: value});
  }


  setupOptions(res:any) {
    var temp_tournys:any[] = res;
    var options:SelectOption[] = temp_tournys
      .filter(e => e.program === "FLL_CHALLENGE")
      .filter(e => e.season === this.state.eventData?.season)
      .map(({name, _id}) => ({label: name, value: _id}));
    this.setState({tournament_options: options});
  }

  sendEventUpdate(team_links:TeamLink[]) {
    CJMS_REQUEST_TEAMS().then((teams) => {
      var link_errors:string[] = [];
      for (const team of teams) {
        const team_link = team_links.find(e => e.team_number === team.team_number);
        if (team_link != undefined) {
          team.team_id = team_link?.cloud_team_id;
          CJMS_POST_TEAM_UPDATE(team.team_number, team);
        } else {
          link_errors.push(`[Link Error: ${team.team_number} | ${team.team_name}],`);
        }
      }

      this.setState({link_errors: link_errors});
    });
    
    CJMS_REQUEST_EVENT().then((event) => {
      event.online_link.online_linked = true;
      event.online_link.tournament_id = this.state.selected_tournament;
      event.online_link.tournament_token = this.state.tournament_token;
      CJMS_POST_EVENT_UPDATE(event);
    });
  }

  onLink() {
    if (this.state.eventData && this.state.selected_tournament.length > 0 && this.state.tournament_token.length > 0) {
      CLOUD_REQUEST_TEAMS(this.state.selected_tournament).then((cloud_teams:any) => {
        CJMS_REQUEST_TEAMS().then((teams) => {
          if (teams.length != cloud_teams.length) {
            alert("Invalid cross reference. Number of teams differ");
          }
          const unmatched_teams:string[] = [];
          const matching_teams:TeamLink[] = [];

          for (const team of cloud_teams) {
            const cloud_t_number = `AU-${team.team_number}C`;
            const t = 
              this.state.link_style === CrossCheckStyle.FormattedTeamNumbers ? teams.find(e => String(e.team_number).replaceAll(' ', '').toLowerCase() === String(cloud_t_number).replaceAll(' ', '').toLowerCase()) : 
              this.state.link_style === CrossCheckStyle.TeamNumbers ? teams.find(e => String(e.team_number).replaceAll(' ', '').toLowerCase() === String(team.team_number).replaceAll(' ', '').toLowerCase()) :
              teams.find(e => String(e.team_name).replaceAll(' ', '').toLowerCase() === String(team.team_name).replaceAll(' ', '').toLowerCase());

            // console.log(t);
            if (t != undefined) {
              matching_teams.push({team_number: t.team_number, cloud_team_id: team._id});
            } else {
              unmatched_teams.push(`[Matching Error: ${team.team_number} | ${team.team_name}],`);
            }
          }

          this.setState({matching_teams: matching_teams});
          if ((matching_teams.length != teams.length) || teams.length != cloud_teams.length) {
            alert("Some teams failed to match");
            this.setState({link_errors: unmatched_teams});
          } else {
            this.setState({link_errors: []});
            this.sendEventUpdate(matching_teams);
          }
        });
      });
    } else {
      alert("Invalid Link Data");
    }
  }

  getLinkErrors() {
    if (this.state.link_errors.length > 0) {
      return (
        <div className="link-errors">
          {this.state.link_errors.map((i) => (
            <p key={i}><span style={{color: 'red'}}>{i}</span></p>
          ))}

          <button className="hoverButton back-red" onClick={() => this.sendEventUpdate(this.state.matching_teams)}>Override and Link</button>
        </div>
      );
    }
  }

  getLink() {
    if (this.state.eventData?.online_link?.online_linked) {
      return (
        <>
          <p>
            <span style={{color: 'green'}}>Linked to tournament_id: {this.state.eventData?.online_link?.tournament_id}</span>
          </p>
          {this.getLinkErrors()}
        </>
      );
    } else if (this.state.link_errors.length > 0) {
      return (this.getLinkErrors());
    } else {
      return (<p style={{color: 'red'}}>Unlinked</p>);
    }
  }

  setLinkStyle(style:CrossCheckStyle) {
    this.setState({link_style: style});
  }

  setTournamentToken(token:string) {
    this.setState({tournament_token: token});
  }

  render() {
    return (
      <div className="setup-column online">
        {/* Main Form */}
        <form onSubmit={(e) => {e.preventDefault()}}>
          <p>Online Link (optional)</p>
          <ol>
            <li>Complete Offline Setup</li>
            <li>Select/Search For Event</li>
          </ol>

          {/* FLL Season */}
          <h3>Tournament</h3>
          <Select
            className="selector"
            options={this.state.tournament_options}
            placeholder={`${this.state.tournament_options.length > 0 ? 'Select Tournament' : 'Offline'}`}
            onChange={(tourny) => this.setSelectedTournament(String(tourny?.value))}
          />

          <h3>Cross reference schedule using:</h3>
          <RadioGroup onChange={(e) => this.setLinkStyle(Number(e.target.value))} defaultValue={CrossCheckStyle.FormattedTeamNumbers}>
            <FormControlLabel value={CrossCheckStyle.FormattedTeamNumbers} defaultChecked={true} control={<Radio />} label="Team Numbers (Format: AU-000C)"/>
            <FormControlLabel value={CrossCheckStyle.TeamNumbers} control={<Radio />} label="Team Numbers (Format: 000)"/>
            <FormControlLabel value={CrossCheckStyle.TeamNames} control={<Radio />} label="Team Names"/>
          </RadioGroup>

          <h3>Tournament Token</h3>
          <input placeholder="token..." onChange={(e) => this.setTournamentToken(e.target.value)}/>

          {/* Controls */}
          <button className="hoverButton back-blue" onClick={this.onLink}>Link</button>

          <h2>Link Status:</h2>
          {this.getLink()}
        </form>
      </div>
    );
  }
}