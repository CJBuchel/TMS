import express from "express";
import cors from 'cors';
import bodyParser from "body-parser";

class Requests {
  private requestApp = express();
  constructor() {
    // Setup the request application
    this.requestApp.use(cors());
    this.requestApp.use(express.json());
    this.requestApp.use(bodyParser.urlencoded({
      extended: true
    }));
  }
}