import { comm_service, request_namespaces, ITeamScore, ITeam } from "@cjms_shared/services";
import { TeamModel } from "../../database/models/Team";
import { MatchModel } from "../../database/models/Match";
import { RequestServer } from "../RequestServer";
// var sends = 0;
// var gets = 0;

export class Teams {
  constructor(requestServer:RequestServer) {
    console.log("Team Requests Constructed");

    // returns 0 for first array, 1 for second. -1 for complete tie
    function getNextHighest(arr1:number[], arr2:number[]): number {
      var highest = -1;
      const length = arr1.length;
      for (var i = 0; i < length; i++) {
        if (Math.max(...arr1) > Math.max(...arr2)) {
          highest = 0;
          break;
        } else if (Math.max(...arr1) < Math.max(...arr2)) {
          highest = 1;
          break;
        } else {
          arr1.splice(arr1.indexOf(Math.max(...arr1)), 1);
          arr2.splice(arr2.indexOf(Math.max(...arr2)), 1);
        }
      }

      return highest;
    }

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
              const teamJScores = teams[j].scores.filter((score) => !score.no_show);
              const teamIScores = teams[i].scores.filter((score) => !score.no_show);

              if (Math.max(...teamJScores.map((score:ITeamScore) => score.score)) > Math.max(...teamIScores.map((score:ITeamScore) => score.score))) {
                ranking++;
              } else if (Math.max(...teamJScores.map((score:ITeamScore) => score.score)) === Math.max(...teamIScores.map((score:ITeamScore) => score.score))) {
                if (getNextHighest(teamJScores.map((score:ITeamScore) => score.score), teamIScores.map((score:ITeamScore) => score.score)) === 0) {
                  ranking++;
                }
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
          } else {
            res.send({message: "Server: no data"});
          }
        }
      });
    });

    requestServer.get().post(request_namespaces.request_post_team_update, (req, res) => {
      const team_number:string = req.body.team;
      const update:ITeam = req.body.update;

      // Update team in match model first (primarily for team number updates)
      MatchModel.updateMany({'on_table1.team_number':team_number}, {$set: {'on_table1.team_number': update.team_number}}).then((res1) => {
        MatchModel.updateMany({'on_table2.team_number':team_number}, {$set: {'on_table2.team_number': update.team_number}}).then((res2) => {
          if (res1.modifiedCount > 0 || res2.matchedCount > 0) {
            comm_service.senders.sendMatchUpdateEvent('update');
          }
        });
      }).finally(() => {
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