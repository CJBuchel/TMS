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
        // Instantiate a simple authenticator. You can also easily create
        // your own by implementing the (trivial) `Authenticator` interface.
        const auth = new mhub_1.PlainAuthenticator();
        // Create a hub
        const hub = new mhub_1.Hub(auth);
        // Set up authentication and authorization
        // See README.md for more info on permissions
        auth.setUser("someUser", "somePassword");
        hub.setRights({
            "": {
                // Anonymous/guest
                subscribe: true,
                publish: false,
            },
            admin: true,
            someUser: {
                subscribe: true,
                publish: {
                    someNode: true,
                    otherNode: "/some/**",
                    default: ["/some/**", "/other"], // allow e.g. "/some/foo/bar" and "/other"
                },
            },
        });
        // Create and add some nodes.
        // HeaderStore is a good all-purpose node type, which acts like an Exchange,
        // but also allows to 'pin' certain messages with a `keep: true` header.
        // By setting `persistent: true` in the node's config, such messages are
        // also persisted across reboots.
        const defaultNode = new mhub_1.HeaderStore("default", { persistent: true });
        const otherNode = new mhub_1.HeaderStore("otherNode");
        const someNode = new mhub_1.Exchange("someNode");
        hub.add(defaultNode);
        hub.add(otherNode);
        hub.add(someNode);
        // Set up some bindings between nodes if you need them
        someNode.bind(defaultNode, "/something/**");
        otherNode.bind(defaultNode, "/some/**");
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
            wss.once("error", (err) => reject(err));
            httpServer.listen(port, () => {
                mhub_1.log.info(`WebSocket Server started on port ${port}`);
                resolve(port);
            });
        });
    });
}
function demoInternalConnection(hub) {
    return __awaiter(this, void 0, void 0, function* () {
        // Create a local connection to the hub (i.e. not going through any
        // network connections etc), useful for any in-program exchanges to
        // the hub.
        // You can create as many as you like, and the API is just like your
        // normal networked client.
        const client = new mhub_1.LocalClient(hub, "local");
        client.on("message", (msg, subscriptionId) => {
            mhub_1.log.info(`Received on ${subscriptionId} for ${msg.topic}: ${JSON.stringify(msg.data)}`);
        });
        yield client.connect();
        yield client.login("someUser", "somePassword");
        yield client.subscribe("default", "/something/**", "default-something");
        yield client.publish("someNode", "/something/to/test", { test: "data" }, { keep: true });
        yield client.close();
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        // Configure logging (optional)
        mhub_1.log.logLevel = mhub_1.LogLevel.Debug;
        mhub_1.log.onMessage = (msg) => {
            // This is already the default, but you can override it like this
            console.log(msg); // tslint:disable-line:no-console
        };
        const hub = yield createHub();
        yield startWebsocketServer(hub);
        yield demoInternalConnection(hub);
        mhub_1.log.info("");
        mhub_1.log.info("Use `mhub-client -l` to see the published test message");
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