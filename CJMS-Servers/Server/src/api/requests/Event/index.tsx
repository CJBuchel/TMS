import { comm_service, request_namespaces } from "@cjms_shared/services";
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


    requestServer.get().post(request_namespaces.request_post_event_update, (req, res) => {
      const update = req.body;

      EventModel.findOneAndUpdate({}, update, {}, (err) => {
        if (err) {
          res.send({message: "Error while updating team"});
          console.log(err.message);
        } else {
          res.send({success: true});
          comm_service.senders.sendEventUpdateEvent('update');
        }
      });
    });
  }
}