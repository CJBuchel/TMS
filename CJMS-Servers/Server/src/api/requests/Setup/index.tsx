import { RequestServer } from "../RequestServer";
import { request_namespaces } from "@cjms_shared/services";

export class Setup {
  constructor(requestServer:RequestServer) {
    console.log("Setup Requests Constructed");

    requestServer.get().post(request_namespaces.request_post_setup, (req, res) => {
      res.send({message: "Successfully Imported Setup"});
      console.log(req.body);
    });

    requestServer.get().use(request_namespaces.request_post_purge, (req, res) => {
      res.send({message: "Successfully Purged Database"});
    });
  }
}