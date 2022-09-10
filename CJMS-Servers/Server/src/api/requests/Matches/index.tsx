import { comm_service, request_namespaces } from "@cjms_shared/services";
import { MatchModel } from "../../database/models/Match";
import { RequestServer } from "../RequestServer";


export class Matches {
  constructor(requestServer:RequestServer) {
    console.log("Match Requests Constructed");

    requestServer.get().get(request_namespaces.request_fetch_matches, async (req, res) => {
      const query = MatchModel.find({});
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
    });
  }
}