import { comm_service, request_namespaces } from "@cjms_shared/services";
import { MatchModel } from "../../database/models/Match";
import { RequestServer } from "../RequestServer";


export class Matches {
  constructor(requestServer:RequestServer) {
    console.log("Match Requests Constructed");

    var existing_loadedMatch:boolean = false;
    var load_match:boolean = false;

    function sendLoadedMatch(match:string) {
      if (!existing_loadedMatch) {
        existing_loadedMatch = true;

        const loopInterval = setInterval(loop, 1000);
        function loop() {
          if (load_match) {
            console.log("Loading match: " + match);
            comm_service.senders.sendMatchLoadedEvent(match);
          } else {
            existing_loadedMatch = false;
            clearInterval(loopInterval);
            comm_service.senders.sendMatchLoadedEvent(null);
          }
        }
      }
    }

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

    requestServer.get().post(request_namespaces.request_post_match_load, (req, res) => {
      console.log(req.body);
      if (req.body.load) {
        load_match = true;
        comm_service.senders.sendEventStateEvent("Match Loaded");
        sendLoadedMatch(req.body.match);
      } else {
        comm_service.senders.sendEventStateEvent("Idle");
        comm_service.senders.sendMatchLoadedEvent(null);
        load_match = false;
      }

      res.send({});
    });
  }
}