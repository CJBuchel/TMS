import { comm_service, request_namespaces, ITeamScore, ITeam } from "@cjms_shared/services";
import { TeamModel } from "../../database/models/Team";
import { MatchModel } from "../../database/models/Match";
import { RequestServer } from "../RequestServer";
// var sends = 0;
// var gets = 0;

export class Teams {
  constructor(requestServer:RequestServer) {
    console.log("Team Requests Constructed");

    function updateRankings() {
      const query = TeamModel.find({});
      query.exec(function(err, result) {
        if (err) {
          console.log(err);
        } else {
          const teams:ITeam[] = result;
          for (var i = 0; i < teams.length; i++) {
            var ranking = 1;
            for (var j = 0; j < teams.length; j++) {
              if ( Math.max(...teams[j].scores.map((score:ITeamScore) => score.score)) > Math.max(...teams[i].scores.map((score:ITeamScore) => score.score))) {
                ranking++;
              }
            }
    
            teams[i].ranking = ranking;
            TeamModel.findOneAndUpdate({team_number:teams[i].team_number}, {ranking:ranking}, {}, (err) => {
              if (err) {
                console.log(err);
              }
            });
          }
          comm_service.senders.sendTeamUpdateEvent('update');
        }
      });
    }

    requestServer.get().get(request_namespaces.request_fetch_teams, (req, res) => {
      const query = TeamModel.find({});
      
      query.exec(function (err, response) {
        if (err) {
          console.log(err);
          res.send({message: err});
          throw err;
        } else {
          if (response.length > 0) {
            res.send({data: response.sort((a,b) => {return a.ranking - b.ranking})});
            // gets++;
            // console.log(`Get ${gets} from ${req.socket.remoteAddress}`);
          } else {
            res.send({message: "Server: no data"});
          }
        }
      });
    });

    requestServer.get().post(request_namespaces.request_post_team_update, (req, res) => {
      const team_number:string = req.body.team;
      const update:ITeam = req.body.update;

      // Update team in match model first (primarily for team numbers)
      MatchModel.updateMany({'on_table1.team_number':team_number}, {$set: {'on_table1.team_number': update.team_number}}).then((res1) => {
        MatchModel.updateMany({'on_table2.team_number':team_number}, {$set: {'on_table2.team_number': update.team_number}}).then((res2) => {
          if (res1.modifiedCount > 0 || res2.matchedCount > 0) {
            comm_service.senders.sendMatchUpdateEvent('update');
            // Update team in team model
            const filter = { team_number: team_number };
            TeamModel.findOneAndUpdate(filter, update, {}, (err) => {
              if (err) {
                res.send({message: "Error while updating team"});
                console.log(err.message);
              } else {
                res.send({success: true});
                updateRankings();
              }
            });
          } else {
            res.send({message: "Error while trying to find matching team in schedule"});
          }
        });
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
          // comm_service.senders.sendTeamUpdateEvent('update');
          // sends++;
          // console.log("Post data " + sends);
          updateRankings();
        }
      });
    });
  }
}