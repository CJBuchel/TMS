import { comm_service, request_namespaces } from "@cjms_shared/services";
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

    requestServer.get().post(request_namespaces.request_post_team_score, (req, res) => {
      const score = req.body;
      const update = {
        $push: {scores: {
          roundIndex: score.round,
          score: score.score,
          gp: score.gp,
          scored_by: score.scored_by,
          notes: score.notes,
          no_show: score.no_show
        }}
      };

      const filter = { team_number: score.team_number };
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