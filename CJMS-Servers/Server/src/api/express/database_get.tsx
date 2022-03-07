import ExpressConnection from "./express_connection";
import * as ex_names from "./express_namespaces";
import * as query_scripts from "../mysql/queryScripts";
import { Database } from "../mysql/connection";

class ExpressDatabaseGet {
  constructor(expressConnection:ExpressConnection, dbConnection:Database) {

    // Generic Query Wrapper
    function dbQuery(query:string) {
      return dbConnection.query(query);
    }

    // Generic Query wrapper with place holders
    function dbQueryPH(query:string, objects:any) {
      return dbConnection.query_ph(query, objects);
    }


    // Login Request
    expressConnection.get().get(ex_names.express_database_get_login, (req:any, res:any) => {
      const username = req.body.user;
      const password = req.body.password;
      const response = dbQueryPH(query_scripts.sql_get_user, [username, password]);

      if (response.err) {
        res.send(response);
      } else {
        if (response.result.length > 0) {
          res.send({
            token: "connection-" + Math.random()
          });
        } else {
          res.send({message: "Wrong username/password"});
        }
      }

      console.log(response);
    });

    
  }
}