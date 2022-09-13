import MHubClient_node from "mhub/dist/src/nodeclient";
import MHubClient_browser from "mhub/dist/src/browserclient";

var client:any;

if (typeof window !== 'undefined') {
  client = new MHubClient_browser(`ws://${window.location.hostname}:2122`);
} else {
  client = new MHubClient_node("ws://localhost:2122");
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

export function sendEvent(type, event, e) {
  return login()
  // .then(() => console.log(`Sending ${event} to comm server`))
  .then(() => client.publish("cjms_node", `${type}:${event}`, e));
}