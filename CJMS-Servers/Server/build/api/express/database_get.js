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
class ExpressDatabaseGet {
    constructor(expressConnection, dbConnection) {
        // Generic Query Wrapper
        function dbQuery(query) {
            return dbConnection.query(query);
        }
        // Generic Query wrapper with place holders
        function dbQueryPH(query, objects) {
            return dbConnection.query_ph(query, objects);
        }
        // Login Request
        expressConnection.get().get(ex_names.express_database_get_login, (req, res) => {
            const username = req.body.user;
            const password = req.body.password;
            const response = dbQueryPH(query_scripts.sql_get_user, [username, password]);
            if (response.err) {
                console.log("Query Error");
                res.send(response.err);
            }
            else {
                if (response.result.length > 0) {
                    res.send({
                        token: "connection-" + Math.random()
                    });
                }
                else {
                    res.send({ message: "Wrong username/password" });
                }
            }
        });
        // Get Match Schedule
        expressConnection.get().get(ex_names.express_database_get_match_schedule, (req, res) => {
            const response = dbQuery(query_scripts.sql_get_all_match_schedule);
            if (response.err) {
                console.log("Query Error");
                res.send(response.err);
            }
            else {
                res.send(response);
            }
        });
        // Get Judging Schedule
        expressConnection.get().get(ex_names.express_database_get_judging_schedule, (req, res) => {
            const response = dbQuery(query_scripts.sql_get_all_judging_schedule);
            if (response.err) {
                console.log("Query Error");
                res.send(response.err);
            }
            else {
                res.send(response);
            }
        });
        // Get Matches
        expressConnection.get().get(ex_names.express_database_get_matches, (req, res) => {
            const response = dbQuery(query_scripts.sql_get_matches);
            if (response.err) {
                console.log("Query Error");
                res.send(response.err);
            }
            else {
                res.send(response);
            }
        });
        // Get Teams
        expressConnection.get().get(ex_names.express_database_get_teams, (req, res) => {
            const response = dbQuery(query_scripts.sql_get_teams);
            if (response.err) {
                console.log("Query Error");
                res.send(response.err);
            }
            else {
                res.send(response);
            }
        });
    }
}
exports.default = ExpressDatabaseGet;
