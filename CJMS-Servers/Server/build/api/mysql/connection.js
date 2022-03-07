"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Database = void 0;
const mysql = require('mysql2');
class Database {
    constructor(host = "localhost", port = '/var/run/mysqld/mysqld.sock', user = "cjms", password = "cjms", database = "cjms_database") {
        this.db_connected = false;
        this.db_config = {
            host: host,
            user: user,
            password: password,
            database: database,
            port: port,
        };
    }
    connect() {
        this.db_connection = mysql.createConnection(this.db_config);
        console.log("Connected");
        this.db_connected = true;
    }
    get_connection() {
        return this.db_connection;
    }
    query(query) {
        var query_response = {
            err: undefined,
            result: undefined,
            fields: undefined,
        };
        if (this.db_connected) {
            this.db_connection.query(query, function (err, results, fields) {
                query_response = {
                    err: err,
                    result: results,
                    fields: fields
                };
                console.log(query_response.results);
            });
        }
        else {
            console.log("DB Not Connected!");
        }
        return query_response;
    }
    query_ph(query, objects) {
        var query_response = {
            err: undefined,
            result: undefined,
            fields: undefined,
        };
        if (this.db_connected) {
            this.db_connection.query(query, objects, function (err, results, fields) {
                query_response = {
                    err: err,
                    result: results,
                    fields: fields
                };
                console.log(query_response.results);
            });
        }
        else {
            console.log("DB Not Connected!");
        }
        return query_response;
    }
}
exports.Database = Database;
