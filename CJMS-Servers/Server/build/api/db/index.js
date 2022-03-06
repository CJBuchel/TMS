"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseConnection = void 0;
const mysql = require('mysql2');
const { networkInterfaces } = require('os');
class DatabaseConnection {
    constructor(host = "localhost", port = 3306, user = "cjms", password = "cjms", database = "cjms-database") {
        this.db_config = {
            host: host,
            user: user,
            password: password,
            database: database,
            port: port,
        };
        console.log(`User hostname: ${host}`);
        const nets = networkInterfaces();
        const results = Object.create(null);
        for (const name of Object.keys(nets)) {
            for (const net of nets[name]) {
                if (net.family === 'IPv4' && !net.internal) {
                    if (!results[name]) {
                        results[name] = [];
                    }
                    results[name].push(net.address);
                    host = net.address;
                    console.log(net.address);
                }
            }
        }
        // console.log(`User hostname: ${host}`);
        // console.log(results);
        // host = internalIpV4();
        // console.log(internalIpV4());
        // console.log(`Local Host: ${host}`);
    }
    connect() {
        return __awaiter(this, void 0, void 0, function* () {
            this.db_connection = yield mysql.createConnection(this.db_config);
            console.log("Connected");
        });
    }
}
exports.DatabaseConnection = DatabaseConnection;
