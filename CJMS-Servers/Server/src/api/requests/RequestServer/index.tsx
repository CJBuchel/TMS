import express from "express";
import cors from 'cors';
import bodyParser from "body-parser";

import request_namespaces from "@cjms_servers/request_namespaces";

export class RequestServer {
  private requestApp = express();
  constructor() {
    // Setup the request application
    this.requestApp.use(cors());
    this.requestApp.use(express.json());
    this.requestApp.use(bodyParser.urlencoded({
      extended: true
    }));
  }

  // Get the express application
  get() {
    return this.requestApp;
  }

  connect(port:number = request_namespaces.request_api_port) {
    this.requestApp.listen(port, () => {
      console.log("Request Server Running on: " + port);
    });
  }
}