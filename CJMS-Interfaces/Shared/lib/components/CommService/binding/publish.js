import MHubClient from "mhub/dist/src/browserclient";
import Promise from 'bluebird';
var client = new MHubClient(`ws://${window.location.hostname}:2122`);
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
        loginPromise = Promise.resolve(client.connect())
            .tap(() => console.log("Trying to login..."))
            .then(() => client.login("cjms", `${process.env.REACT_APP_PASSWORD_KEY}`))
            .tap(() => console.log("Logged into comm server"))
            .tapCatch(err => {
            console.error(`Error while logging into ${err.message}`);
        });
    }
    return loginPromise;
}
export function sendEvent(type, event, e) {
    return login()
        .then(() => console.log(`Sending ${event} to comm server`))
        .then(() => client.publish("cjms_node", `${type}:${event}`, e));
}
