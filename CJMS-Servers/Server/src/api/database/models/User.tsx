import { IUser } from "@cjms_shared/services";
import mongoose from "mongoose";

export const UserSchema = new mongoose.Schema<IUser>({
  username: {type: String},
  password: {type: String}
});

export const UserModel = mongoose.model<IUser>('User', UserSchema);

export function setupUsers() {
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
}