"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Database = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const user_1 = require("./models/user");
class Database {
    constructor() {
        // Db config
        this.dbConfg = {
            url: 'mongodb://localhost:27017',
            dbName: 'cjms_database',
            user: 'cjms',
            pass: 'cjms',
            autoCreate: true
        };
        mongoose_1.default.connect(this.dbConfg.url, {
            dbName: this.dbConfg.dbName,
            user: this.dbConfg.user,
            pass: this.dbConfg.pass,
            autoCreate: this.dbConfg.autoCreate
        }).then(() => {
            console.log("CJMS Database Connected");
            const query = user_1.UserModel.find({ username: 'admin' });
            query.exec(function (err, user) {
                if (err) {
                    throw err;
                }
                else {
                    console.log(user);
                    if (user.length > 0) {
                        console.log("Users already exist. Continuing setup");
                    }
                    else {
                        console.log("Users undefined, creating defaults");
                        new user_1.UserModel({ username: 'admin', password: 'password' }).save();
                        new user_1.UserModel({ username: 'scorekeeper', password: 'password' }).save();
                        new user_1.UserModel({ username: 'referee', password: 'password' }).save();
                        new user_1.UserModel({ username: 'head_referee', password: 'password' }).save();
                    }
                }
            });
        }).catch((error) => {
            console.log("Error Connecting to Database");
            console.error(error);
        });
    }
}
exports.Database = Database;
