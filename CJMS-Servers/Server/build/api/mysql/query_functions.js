"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateRankings = void 0;
const query_scripts = __importStar(require("./query_scripts"));
// Generic function to update rankings in database
// Called every score update and team modify
function updateRankings(db) {
    const response = db.query(query_scripts.sql_get_teams);
    if (response.err) {
        console.log("Error updating ranks");
        console.log(response.err);
    }
    else {
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
            teams.push({ name: team.team_name, highest_score: highest, rank: 0 });
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
exports.updateRankings = updateRankings;
