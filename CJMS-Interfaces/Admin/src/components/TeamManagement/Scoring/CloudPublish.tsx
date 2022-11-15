import { CJMS_POST_TEAM_UPDATE, CLOUD_DELETE_SCORESHEET, CLOUD_POST_SCORESHEET, CLOUD_REQUEST_SCORESHEETS } from "@cjms_interfaces/shared";
import { IEvent, ITeam } from "@cjms_shared/services";
import { Button } from "@mui/material";
import { Component } from "react";

interface IProps {
  external_eventData:IEvent;
  external_teamData:ITeam[];
}

interface IState {}

export default class CloudPublish extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}

    this.handleCloudPublish = this.handleCloudPublish.bind(this);
    this.handleCloudDelete = this.handleCloudDelete.bind(this);
  }

  publishScoresheets() {
    this.props.external_teamData.forEach((team) => {
      const onlineLink = this.props.external_eventData.online_link;
      if (team.team_id.length > 0 && onlineLink.tournament_id.length > 0 && onlineLink.tournament_token.length > 0 && onlineLink.online_linked) {
        for (const score of team.scores) {
          if (team.scores.filter((sc) => sc.scoresheet.round === score.scoresheet.round).length === 1) {
            if (score.valid_scoresheet && !score.cloud_published && !score.no_show) {
              score.scoresheet.team_id = team.team_id;
              score.scoresheet.tournament_id = onlineLink.tournament_id;
              CLOUD_POST_SCORESHEET(onlineLink.tournament_token, score.scoresheet).then((response:any) => {
                if (response.compete_id) {
                  score.cloud_published = true;
                  CJMS_POST_TEAM_UPDATE(team.team_number, team);
                }
              }).catch((err) => {
                alert(`Error posting team: ${team.team_number}`);
                console.log(err);
              });
            }
          } else {
            console.log(`Conflict with: ${team.team_name}`);
          }
        }
      }
    });
  }

  deleteScoresheets() {
    // the api returns a non standard scoresheet when gettings all scores from tournament
    var status_ok = true;
    CLOUD_REQUEST_SCORESHEETS(this.props.external_eventData.online_link.tournament_id).then(async (response:any) => {
      // var response_success:boolean = false;
      for (const scoresheet of response) {
        await CLOUD_DELETE_SCORESHEET(
          this.props.external_eventData.online_link.tournament_token, 
          this.props.external_eventData.online_link.tournament_id, 
          scoresheet._id
        ).then((response) => {
          if (response.status !== 200 || !response.ok) {
            status_ok = false;
            alert(`Error score: ${scoresheet._id}`);
          }
        });
      }

    }).finally(() => {
      if (status_ok) {
        for (const team of this.props.external_teamData) {
          for (const score of team.scores) {
            score.cloud_published = false;
          }
  
          CJMS_POST_TEAM_UPDATE(team.team_number, team);
        }
      }
    });
  }

  handleCloudPublish() {
    if (confirm("Confirm Publish")) {
      this.publishScoresheets();
    }
  }

  handleCloudDelete() {
    if (confirm("Confirm Delete")) {
      this.deleteScoresheets();
    }
  }

  render() {
    return (
      <>
        <Button
          variant="outlined"
          onClick={this.handleCloudPublish}
          sx={{
            // right: '0px',
            margin: '10px',
            marginRight: '10px',
            fontSize: '25px',
            float: 'right',
            borderColor: 'red',
            color: 'cyan'
          }}
        >Cloud Bulk Publish</Button>
        <Button
          variant="outlined"
          onClick={this.handleCloudDelete}
          sx={{
            // right: '0px',
            margin: '10px',
            marginRight: '10px',
            fontSize: '25px',
            float: 'right',
            borderColor: 'cyan',
            color: 'red'
          }}
        >Cloud Bulk Delete</Button>
      </>
    )
  }
}