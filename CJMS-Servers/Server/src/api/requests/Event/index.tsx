import { request_namespaces } from "@cjms_shared/services";
import { EventModel } from "../../database/models/Event";
import { RequestServer } from "../RequestServer";

export class Event {
  constructor(requestServer:RequestServer) {
    console.log("Event Requests Constructed");

    requestServer.get().get(request_namespaces.request_fetch_event, (req, res) => {
      const query = EventModel.findOne({});
      query.exec(function(err, response) {
        if (err) {
          console.log(err);
          res.send({message: "Server: Event db error"});
          throw err;
        } else {
          res.send({data: response});
        }
      });
    });
  }
}