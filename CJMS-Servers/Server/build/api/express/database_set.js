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
const ex_names = __importStar(require("./express_namespaces"));
const query_scripts = __importStar(require("../mysql/query_scripts"));
class ExpressDatabaseSet {
    constructor(expressConnection, dbConnection) {
        // Generic Query Wrapper
        function dbQuery(query) {
            return dbConnection.query(query);
        }
        // Generic Query wrapper with place holders
        function dbQueryPH(query, objects) {
            return dbConnection.query_ph(query, objects);
        }
        // Purge Database
        expressConnection.get().get(ex_names.express_database_set_purge, (req, res) => {
            for (const purge_script of query_scripts.get_sql_purge_script(query_scripts.sql_table_names_arr)) {
                const response = dbQuery(purge_script);
                if (response.err) {
                    console.log(response.err);
                    res.send(response.err);
                }
                else {
                    res.send(response);
                }
            }
        });
        // Update User
        expressConnection.get().get(ex_names.express_database_set_user, (req, res) => {
            const user = req.body.user;
            const new_password = req.body.pass;
            const response = dbQueryPH(query_scripts.sql_update_user, [new_password, user]);
            if (response.err) {
                console.log(response.err);
                res.send(response.err);
                res.send({ message: "Error Updating User" });
            }
            else {
                res.send(response);
            }
        });
        // Update Team (Remember to update rankings after modify)
        expressConnection.get().get(ex_names.express_database_set_team, (req, res) => {
            const old_team = req.body.old_team;
            const new_team = req.body.new_team;
            if (old_team.team_number === undefined) {
                console.log("Error Team Undefined");
                res.send(old_team);
            }
            else {
                const response = dbQueryPH(query_scripts.sql_update_team_row, [
                    // New data
                    new_team.team_number,
                    new_team.team_name,
                    new_team.affiliation,
                    new_team.match_score_1,
                    new_team.match_score_2,
                    new_team.match_score_3,
                    new_team.match_gp_1,
                    new_team.match_gp_2,
                    new_team.match_gp_2,
                    new_team.ranking,
                    // Where
                    old_team.team_number
                ]);
                if (response.err) {
                    console.log("Error Updating Team");
                    res.send(response.err);
                }
                else {
                    res.send(response);
                }
            }
        });
    }
}
exports.default = ExpressDatabaseSet;
