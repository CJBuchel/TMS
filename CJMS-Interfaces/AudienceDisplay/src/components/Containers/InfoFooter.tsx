import { IEvent, IMatch, ITeam } from "@cjms_shared/services";
import { Component } from "react";

import "../../assets/stylesheets/InfoFooter.scss";
import Timer from "./Timer";

interface IProps {
  eventData:IEvent;
  teamData:ITeam[],
  matchData:IMatch[],
  loaded_match:IMatch;
}

interface IState {}

export default class InfoFooter extends Component<IProps, IState> {
  render() {
    return (
      <div className="info-footer-wrapper">
        <div className="info-footer">

          {/* Top info */}
          <div className="event-info">
            <div className="event-info-name">
              <span>{this.props.eventData.event_name}</span>
            </div>
            <div className="event-info-match">
              <span>
                {this.props.loaded_match.match_number.length > 0 ? `Match ${this.props.loaded_match.match_number}/${this.props.matchData.length}` : `No Match Loaded`}
              </span>
            </div>
          </div>

          {/* Match info */}
          <div className="match-info">
            <div className="match-info-on-table">
              <div className="on-table-span">
                <span>On Table: <span style={{fontWeight: 'bold'}}>{this.props.loaded_match.on_table1.table}</span></span>
              </div>
              <div className="on-table-team-span">
                <span>{this.props.loaded_match.on_table1.team_number} | {this.props.teamData.find((team) => team.team_number === this.props.loaded_match.on_table1.team_number)?.team_name}</span>
              </div>
            </div>

            <div className="match-info-timer">
              <Timer/>
            </div>

            <div className="match-info-on-table">
              <div className="on-table-span">
                <span>On Table: <span style={{fontWeight: 'bold'}}>{this.props.loaded_match.on_table2.table}</span></span>
              </div>
              <div className="on-table-team-span">
                <span>{this.props.loaded_match.on_table2.team_number} | {this.props.teamData.find((team) => team.team_number === this.props.loaded_match.on_table2.team_number)?.team_name}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}