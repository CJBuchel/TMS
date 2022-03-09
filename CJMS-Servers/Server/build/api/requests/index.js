"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const body_parser_1 = __importDefault(require("body-parser"));
class Requests {
    constructor() {
        this.requestApp = (0, express_1.default)();
        // Setup the request application
        this.requestApp.use((0, cors_1.default)());
        this.requestApp.use(express_1.default.json());
        this.requestApp.use(body_parser_1.default.urlencoded({
            extended: true
        }));
    }
}
