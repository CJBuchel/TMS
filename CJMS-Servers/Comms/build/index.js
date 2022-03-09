"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const http = __importStar(require("http"));
require("source-map-support/register");
const ws = __importStar(require("ws"));
const mhub_1 = require("mhub");
// Setup the main hub for communication (designated by cjms_node)
function createHub() {
    return __awaiter(this, void 0, void 0, function* () {
        const auth = new mhub_1.PlainAuthenticator();
        const hub = new mhub_1.Hub(auth);
        auth.setUser("cjms", "cjms");
        hub.setRights({
            // Guests
            "": {
                subscribe: true,
                publish: false
            },
            admin: true,
            cjms: true, // allow everything
        });
        const cjms_node = new mhub_1.HeaderStore("cjms_node");
        hub.add(cjms_node);
        yield hub.init();
        return hub;
    });
}
// Startup websocket & http server listening
function startServer(hub) {
    return __awaiter(this, void 0, void 0, function* () {
        const httpServer = http.createServer();
        const wss = new ws.Server({ server: httpServer });
        let connectionId = 0;
        wss.on("connection", (conn) => new mhub_1.WSConnection(hub, conn, "websocket" + connectionId++));
        const port = 2122;
        yield new Promise((resolve, reject) => {
            wss.once("error", (err) => {
                console.log(err);
                reject(err);
            });
            httpServer.listen(port, () => {
                mhub_1.log.info("Websocket Server started on: " + port);
            });
        });
    });
}
function Server() {
    return __awaiter(this, void 0, void 0, function* () {
        mhub_1.log.logLevel = mhub_1.LogLevel.Debug;
        mhub_1.log.onMessage = (msg) => {
            console.log(msg);
        };
        const hub = yield createHub();
        yield startServer(hub);
        mhub_1.log.info("Comm Server Active");
    });
}
function die(fmt, ...args) {
    mhub_1.log.fatal(fmt, ...args);
    process.exit(1);
}
// Startup the Comm Server
Server().catch((err) => die("Comm Server Crashed!", err));
