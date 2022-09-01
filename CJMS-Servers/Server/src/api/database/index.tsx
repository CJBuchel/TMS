import mongoose from "mongoose";
import { setupUsers, UserModel } from "./models/User";

export class Database {

  // Db config
  public dbConfg = {
    url: 'mongodb://localhost:27017',
    dbName: 'cjms_database',
    user: 'cjms',
    pass: 'cjms',
    autoCreate: true
  }

  constructor() {
    mongoose.connect(this.dbConfg.url, {
      dbName: this.dbConfg.dbName,
      user: this.dbConfg.user,
      pass: this.dbConfg.pass,
      autoCreate: this.dbConfg.autoCreate
    }).then(() => {
      console.log("CJMS Database Connected");
      setupUsers();
    }).catch((error) => {
      console.log("Error Connecting to Database");
      console.error(error);
    });
  }
}