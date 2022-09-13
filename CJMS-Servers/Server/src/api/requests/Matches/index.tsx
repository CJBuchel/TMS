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
            comm_service.senders.sendMatchLoadedEvent(match);
          } else {
            clearInterval(loopInterval);
            existing_loadedMatch = false;
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
      if (req.body.load) {
        load_match = true;
        sendLoadedMatch(req.body.match);
      } else {
        load_match = false;
      }
    });
  }
}