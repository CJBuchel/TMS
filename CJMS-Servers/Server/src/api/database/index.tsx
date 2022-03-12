import mongoose from "mongoose";
import { UserModel } from "./models/User";

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

      const query = UserModel.find({username: 'admin'});
      query.exec(function(err, user) {
        if (err) {
          throw err;
        } else {
          console.log(user);
          if (user.length > 0) {
            console.log("Users already exist. Continuing setup");
          } else {
            console.log("Users undefined, creating defaults");
            new UserModel({username: 'admin', password: 'password'}).save();
            new UserModel({username: 'scorekeeper', password: 'password'}).save();
            new UserModel({username: 'referee', password: 'password'}).save();
            new UserModel({username: 'head_referee', password: 'password'}).save();
          }
        }
      });
    }).catch((error) => {
      console.log("Error Connecting to Database");
      console.error(error);
    });
  }
}