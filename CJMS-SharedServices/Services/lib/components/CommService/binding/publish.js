"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendEvent = void 0;
const nodeclient_1 = require("mhub/dist/src/nodeclient");
const browserclient_1 = require("mhub/dist/src/browserclient");
var client;
if (typeof window !== 'undefined') {
    client = new browserclient_1.default(`ws://${window.location.hostname}:2122`);
}
else {
    client = new nodeclient_1.default("ws://localhost:2122");
}
let loginPromise = null;
client.on('error', msg => {
    console.error("Error, unable to connect to comm server: \n" + msg);
});
client.on('close', () => {
    loginPromise = null;
    console.warn("Disconnected from comm server");
});
function login() {
    if (!loginPromise) {
        console.log("Connecting to comm server...");
        // console.log("CommServer Url: " + client.url + `password: ${process.env.REACT_APP_PASSWORD_KEY}`);
        loginPromise = Promise.resolve(client.connect())
            .then(() => client.login("cjms", `${process.env.REACT_APP_PASSWORD_KEY}`))
            .catch((err) => {
            console.error(`Error while logging into comm server ${err.message}`);
            loginPromise = null;
        });
    }
    return loginPromise;
}
function sendEvent(type, event, e) {
    return login()
        // .then(() => console.log(`Sending ${event} to comm server`))
        .then(() => client.publish("cjms_node", `${type}:${event}`, e));
}
exports.sendEvent = sendEvent;
