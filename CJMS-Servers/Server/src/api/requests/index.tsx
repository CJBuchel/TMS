import express from "express";
import cors from 'cors';
import bodyParser from "body-parser";

export class Requests {
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

  connect(port: 2121) {
    this.requestApp.listen(port, () => {
      console.log("Request Server Running on: " + port);
    });
  }
}