"use strict";
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
const http = require("http");
require("source-map-support/register");
const ws = require("ws");
// Replace ".." with "mhub" in your own programs
const mhub_1 = require("mhub");
function createHub() {
    return __awaiter(this, void 0, void 0, function* () {
        const auth = new mhub_1.PlainAuthenticator();
        // Create a hub
        const hub = new mhub_1.Hub(auth);
        auth.setUser("cj_fss", "fss");
        hub.setRights({
            "": {
                // Anonymous/guest
                subscribe: true,
                publish: false,
            },
            admin: true,
            cj_fss: true,
        });
        const cj_node = new mhub_1.HeaderStore("cj_node");
        hub.add(cj_node);
        // cj_node.bind(defaultNode)
        // Configure storage on disk by using the simple built-in storage drivers
        const simpleStorage = new mhub_1.ThrottledStorage(new mhub_1.SimpleFileStorage("./my-storage"));
        hub.setStorage(simpleStorage);
        // Initialize nodes (e.g. load persistent messages from disk)
        yield hub.init();
        return hub;
    });
}
function startWebsocketServer(hub) {
    return __awaiter(this, void 0, void 0, function* () {
        // Create transports to the server, in this case a websocket server.
        // See `nodeserver.ts` for more examples, including https and plain TCP.
        // You can use the same `httpServer` for attaching to e.g. your Express API.
        // You can also use a custom path for the websocket.
        const httpServer = http.createServer();
        const wss = new ws.Server({ server: httpServer });
        let connectionId = 0;
        wss.on("connection", (conn) => new mhub_1.WSConnection(hub, conn, "websocket" + connectionId++));
        const port = 13900;
        yield new Promise((resolve, reject) => {
            wss.once("error", (err) => {
                console.log(err);
                reject(err);
            });
            httpServer.listen(port, () => {
                mhub_1.log.info(`WebSocket Server started on port ${port}`);
                resolve(port);
            });
        });
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        // Configure logging (optional)
        mhub_1.log.logLevel = mhub_1.LogLevel.Info;
        mhub_1.log.onMessage = (msg) => {
            console.log(msg); // tslint:disable-line:no-console
        };
        const hub = yield createHub();
        yield startWebsocketServer(hub);
        mhub_1.log.info("Comm Server Active");
        mhub_1.log.info("using the websocket connection.");
        mhub_1.log.info("Press Ctrl-C to stop the server.");
    });
}
function die(fmt, ...args) {
    mhub_1.log.fatal(fmt, ...args);
    process.exit(1);
}
main().catch((err) => die("main crashed", err));
//# sourceMappingURL=commServer.js.map