import { request_namespaces } from "@cjms_shared/services";
import { TeamModel } from "../../database/models/Team";
import { RequestServer } from "../RequestServer";

export class Teams {
  constructor(requestServer:RequestServer) {
    console.log("Team Requests Constructed");

    requestServer.get().get(request_namespaces.request_fetch_teams, (req, res) => {
      const query = TeamModel.find({});
      query.exec(function(err, response) {
        if (err) {
          console.log(err);
          res.send({message: err});
          throw err;
        } else {
          if (response.length > 0) {
            res.send({data: response});
          } else {
            res.send({message: "Server: no data"});
          }
        }
      });
      // console.log(query);
    });
  }
}