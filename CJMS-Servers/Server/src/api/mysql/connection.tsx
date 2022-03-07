const mysql = require('mysql2');

export class Database {
  db_config:any;
  db_connection:any;
  private db_connected:boolean = false;
  constructor(host:string = "localhost", port:any = '/var/run/mysqld/mysqld.sock', user:string = "cjms", password:string = "cjms", database:string = "cjms_database") {
    this.db_config = {
      host: host,
      user: user,
      password: password,
      database: database,
      port: port,
    }
  }

  connect() {
    this.db_connection = mysql.createConnection(this.db_config);
    console.log("Connected");
    this.db_connected = true;
  }

  get_connection() {
    return this.db_connection;
  }

  query(query:any) {
    var query_response:any = {
      err: undefined,
      result: undefined,
      fields: undefined,
    };

    if (this.db_connected) {
      this.db_connection.query(query, function(err:any, results:any, fields:any) {
        query_response = {
          err: err,
          result: results,
          fields: fields
        }
        console.log(query_response.results);
      });
    } else {
      console.log("DB Not Connected!");
    }

    return query_response;
  }

  query_ph(query:any, objects:any) {
    var query_response:any = {
      err: undefined,
      result: undefined,
      fields: undefined,
    };
    
    if (this.db_connected) {
      this.db_connection.query(query, objects, function(err:any, results:any, fields:any) {
        query_response = {
          err: err,
          result: results,
          fields: fields
        }
        console.log(query_response.results);
      });
    } else {
      console.log("DB Not Connected!");
    }

    return query_response;
  }
}