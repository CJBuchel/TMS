"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const db_1 = require("./api/db");
const app = (0, express_1.default)();
const port = 2121;
let cjms_db = new db_1.DatabaseConnection();
cjms_db.connect();
// app.listen(port, () => {
//   console.log(`Server Running on port ${port}`);
// });
