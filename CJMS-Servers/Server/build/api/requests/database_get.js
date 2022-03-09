"use strict";
// import ExpressConnection from "./express_connection";
// import { Database } from "../mysql/connection";
// import * as ex_names from "./express_namespaces";
// import * as query_scripts from "../mysql/query_scripts";
// class ExpressDatabaseGet {
//   constructor(expressConnection:ExpressConnection, dbConnection:Database) {
//     // Generic Query Wrapper
//     function dbQuery(query:string) {
//       return dbConnection.query(query);
//     }
//     // Generic Query wrapper with place holders
//     function dbQueryPH(query:string, objects:any) {
//       return dbConnection.query_ph(query, objects);
//     }
//     // Login Request
//     expressConnection.get().get(ex_names.express_database_get_login, (req:any, res:any) => {
//       const username = req.body.user;
//       const password = req.body.password;
//       const response = dbQueryPH(query_scripts.sql_get_user, [username, password]);
//       if (response.err) {
//         console.log("Query Error");
//         res.send(response.err);
//       } else {
//         if (response.result.length > 0) {
//           res.send({
//             token: "connection-" + Math.random()
//           });
//         } else {
//           res.send({message: "Wrong username/password"});
//         }
//       }
//     });
//     // Get Match Schedule
//     expressConnection.get().get(ex_names.express_database_get_match_schedule, (req:any, res:any) => {
//       const response = dbQuery(query_scripts.sql_get_all_match_schedule);
//       if (response.err) {
//         console.log("Query Error");
//         res.send(response.err);
//       } else {
//         res.send(response);
//       }
//     });
//     // Get Judging Schedule
//     expressConnection.get().get(ex_names.express_database_get_judging_schedule, (req:any, res:any) => {
//       const response = dbQuery(query_scripts.sql_get_all_judging_schedule);
//       if (response.err) {
//         console.log("Query Error");
//         res.send(response.err);
//       } else {
//         res.send(response);
//       }
//     });
//     // Get Matches
//     expressConnection.get().get(ex_names.express_database_get_matches, (req:any, res:any) => {
//       const response = dbQuery(query_scripts.sql_get_matches);
//       if (response.err) {
//         console.log("Query Error");
//         res.send(response.err);
//       } else {
//         res.send(response);
//       }
//     });
//     // Get Teams
//     expressConnection.get().get(ex_names.express_database_get_teams, (req:any, res:any) => {
//       const response = dbQuery(query_scripts.sql_get_teams);
//       if (response.err) {
//         console.log("Query Error");
//         res.send(response.err);
//       } else {
//         res.send(response);
//       }
//     });
//   }
// }
// export default ExpressDatabaseGet;
