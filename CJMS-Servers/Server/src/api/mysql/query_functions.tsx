import { Database } from "./connection";
import * as query_scripts from "./query_scripts";


// Generic function to update rankings in database
// Called every score update and team modify
export function updateRankings(db:Database) {
  const response = db.query(query_scripts.sql_get_teams);
  if (response.err) {
    console.log("Error updating ranks");
    console.log(response.err);
  } else {
    var teams = []; // Buffer team array

    // Find highest score from each team and store them in the `teams` arr
    for (const team of response.result) {
      var scores = [team.match_score_1, team.match_score_2, team.match_score_3];
      var highest = 0;
      for (var i = 0; i < scores.length; i++) {
        highest = scores[i];
      }

      if (highest === null || highest === undefined) {
        highest = 0;
      }

      teams.push({name: team.team_name, highest_score: highest, rank: 0});
    }

    // Iterate over teams and rank them
    for (var i = 0; i < teams.length; i++) {
      var ranking = 1;
      for (var j = 0; j < teams.length; j++) {
        if (teams[j].highest_score > teams[i].highest_score) {
          ranking++;
        }
      }

      teams[i].rank = ranking;
    }

    // Query DB and update the ranks
    for (const team of teams) {
      db.query(query_scripts.get_sql_update_team('ranking', team.rank.toString(), 'team_name', team.name));
    }

    // Send update?
  }
}