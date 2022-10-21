import { RequestServer } from "../RequestServer";
import { request_namespaces } from "@cjms_shared/services";

import { UserModel } from "../../database/models/User";

export class Users {
  constructor(requestServer:RequestServer) {
    console.log("User Requests Constructed");

    // Login
    requestServer.get().use(request_namespaces.request_post_user_login, (req, res) => {
      console.log(req.body);
      const username = req.body.username;
      const password = req.body.password;

      const query = UserModel.find({username: username, password: password});
      query.exec(function(err, user) {
        if (err) {
          console.log(err);
          res.send({message: "Server: User Login Error"});
          throw err;
        } else {
          if (user.length > 0) {
            res.send({token: "connection-" + Math.random().toString()});
          } else {
            console.log("Incorrect user access");
            res.send({message: "Server: Incorrect Username/Password"});
          }
        }
      });
    });


    // update users
    requestServer.get().post(request_namespaces.request_post_user_update, (req, res) => {
      console.log(req.body);

      const filter = {username: req.body.user};
      const update = {password: req.body.password};

      UserModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          res.send({message: "Server: User change error"});
          throw err;
        } else {
          res.send({message: "Server: User Update Success"});
        }
      });
    });
  }
}