const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

class ExpressConnection {
  private app:any;
  constructor() {
    // Setup Express Application
    this.app = express();

    this.app.use(cors());
    this.app.use(express.json());
    this.app.use(bodyParser.urlencoded({
      extended: true
    }));
  }

  get() {
    return this.app;
  }

  start(port:number) {
    this.app.listen(port, () => {
      console.log("CJMS Express Server Started on " + port);
    });
  }
}

export default ExpressConnection;