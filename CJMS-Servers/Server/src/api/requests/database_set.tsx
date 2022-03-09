// import ExpressConnection from "./express_connection";
// import { Database } from "../mysql/connection";
// import * as ex_names from "./express_namespaces";
// import * as query_scripts from "../mysql/query_scripts";
// import { updateRankings } from "../mysql/query_functions";

// class ExpressDatabaseSet {
//   constructor(expressConnection:ExpressConnection, dbConnection:Database) {
//     // Generic Query Wrapper
//     function dbQuery(query:string) {
//       return dbConnection.query(query);
//     }

//     // Generic Query wrapper with place holders
//     function dbQueryPH(query:string, objects:any) {
//       return dbConnection.query_ph(query, objects);
//     }

//     // Purge Database
//     expressConnection.get().post(ex_names.express_database_set_purge, (req:any, res:any) => {
//       for (const purge_script of query_scripts.get_sql_purge_script(query_scripts.sql_table_names_arr)) {
//         const response = dbQuery(purge_script);
//         if (response.err) {
//           console.log(response.err);
//           res.send(response.err);
//         } else {
//           res.send(response);
//         }
//       }
//     });

//     // Update User
//     expressConnection.get().post(ex_names.express_database_set_user, (req:any, res:any) => {
//       const user = req.body.user;
//       const new_password = req.body.pass;
//       const response = dbQueryPH(query_scripts.sql_update_user, [new_password, user]);
//       if (response.err) {
//         console.log(response.err);
//         res.send(response.err);
//         res.send({message: "Error Updating User"});
//       } else {
//         res.send(response);
//       }
//     });

//     // Update Team (Remember to update rankings after modify)
//     expressConnection.get().post(ex_names.express_database_set_team, (req:any, res:any) => {
//       const old_team = req.body.old_team;
//       const new_team = req.body.new_team;
//       if (old_team.team_number === undefined) {
//         console.log("Error Team Undefined");
//         res.send(old_team);
//       } else {
//         const response = dbQueryPH(query_scripts.sql_update_team_row, [

//           // New data
//           new_team.team_number,
//           new_team.team_name,
//           new_team.affiliation,

//           new_team.match_score_1,
//           new_team.match_score_2,
//           new_team.match_score_3,

//           new_team.match_gp_1,
//           new_team.match_gp_2,
//           new_team.match_gp_2,

//           new_team.ranking,

//           // Where
//           old_team.team_number
//         ]);

//         if (response.err) {
//           console.log("Error Updating Team");
//           res.send(response.err);
//         } else {
//           res.send(response);
//         }
//       }
//     });

//     // Update ranks
//     expressConnection.get().post(ex_names.express_database_set_update_rankings, (req:any, res:any) => {
//       updateRankings(dbConnection);
//     });

//     // Set score
//     expressConnection.get().post(ex_names.express_database_set_team_score, (req:any, res:any) => {
//       function checkNull(value:any) {
//         if (value === null || value === undefined) { 
//           res.send({message: "Unknown value send, (submit again)"});
//           return true; 
//         } else { 
//           return false;
//         }
//       }

//       if (checkNull(req.body.rank_number)) { return; }
//       if (checkNull(req.body.team_score)) { return; }
//       if (checkNull(req.body.team_gp)) { return; }

//       var match_sql = "match_score_"+req.body.rank_number.toString();
//       var gp_sql = "match_score_"+req.body.rank_number.toString();
//       var notes_sql = "match_score_"+req.body.rank_number.toString();

//     });
//   }
// }

// export default ExpressDatabaseSet;