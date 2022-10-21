import { comm_service, request_namespaces, ITeamScore, ITeam } from "@cjms_shared/services";
import { TeamModel } from "../../database/models/Team";
import { RequestServer } from "../RequestServer";

export class Teams {
  constructor(requestServer:RequestServer) {
    console.log("Team Requests Constructed");

    requestServer.get().get(request_namespaces.request_fetch_teams, (req, res) => {
      const query = TeamModel.find({});
      query.exec(function(err, response) {
        if (err) {
          console.log(err);
          res.send({message: err});
          throw err;
        } else {
          if (response.length > 0) {
            res.send({data: response});
          } else {
            res.send({message: "Server: no data"});
          }
        }
      });
      // console.log(query);
    });

    requestServer.get().post(request_namespaces.request_post_team_update, (req, res) => {
      const team_number:number = req.body.team;
      const update:ITeam = req.body.update;

      console.log("Origin: " + team_number);
      console.log("Update: " + update.team_number);

      const filter = { team_number: team_number };
      TeamModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          res.send({message: "Error while updating team"});
          console.log(err.message);
        } else {
          res.send({success: true});
          comm_service.senders.sendTeamUpdateEvent('update');
        }
      });
    });

    requestServer.get().post(request_namespaces.request_post_team_score, (req, res) => {
      const teamScores:ITeamScore = req.body.score;
      const team_number:string = req.body.team_number;

      const update = {
        $push: {scores: teamScores}
      };

      const filter = { team_number: team_number };
      TeamModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          res.send({message: "Error while updating team"});
          console.log(err.message);
        } else {
          res.send({success: true});
          comm_service.senders.sendTeamUpdateEvent('update');
        }
      });
    });
  }
}