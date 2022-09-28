import { comm_service, request_namespaces } from "@cjms_shared/services";
import { MatchModel } from "../../database/models/Match";
import { RequestServer } from "../RequestServer";


export class Matches {
  constructor(requestServer:RequestServer) {
    console.log("Match Requests Constructed");

    requestServer.get().get(request_namespaces.request_fetch_matches, (req, res) => {
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

    requestServer.get().post(request_namespaces.request_post_match_complete, (req, res) => {
      console.log(req.body);
      
      const filter = {match_number: req.body.match};
      const update = {complete: req.body.complete};

      MatchModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          res.send({message: "Error while updating team"});
          console.log(err.message);
        } else {
          res.send({});
          comm_service.senders.sendMatchUpdateEvent('update');
        }
      });

    });

    requestServer.get().post(request_namespaces.request_post_match_update, (req, res) => {
      console.log(req.body);

      const filter = {match_number: req.body.match};
      const update = req.body.update;

      MatchModel.findOneAndUpdate(filter, update, {}, (err) => {
        if (err) {
          res.send({message: "Error while updating team"});
          console.log(err.message);
        } else {
          res.send({success: true});
          comm_service.senders.sendMatchUpdateEvent('update');
        }
      });
    });
  }
}