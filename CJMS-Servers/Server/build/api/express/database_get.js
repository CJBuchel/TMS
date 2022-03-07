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
const query_scripts = __importStar(require("../mysql/queryScripts"));
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
                res.send(response);
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
            console.log(response);
        });
    }
}
