import mongoose from "mongoose";

export const UserSchema = new mongoose.Schema({
  username: {type: String},
  password: {type: String}
});

export const UserModel = mongoose.model('User', UserSchema);