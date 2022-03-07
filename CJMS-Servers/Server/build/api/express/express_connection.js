"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
class ExpressConnection {
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
    start(port) {
        this.app.listen(port, () => {
            console.log("CJMS Express Server Started on " + port);
        });
    }
}
exports.default = ExpressConnection;
