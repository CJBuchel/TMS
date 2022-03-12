import MHubClient from "mhub/dist/src/browserclient";
var client = new MHubClient(`ws://${window.location.hostname}:2122`);

const RETRY_TIMEOUT = 1000; // 1 seccond

const listeners = [];

let connectPromise = null;

// Connection promise
function connect() {
  if (!connectPromise) {
    connectPromise = Promise.resolve(client.connect())
    .then(() => {
      console.log("Connected to Comm Service");
    }).catch(err => {
      console.log(`Error while connecting to Comm service ${err.message}`);
      throw err;
    });
  }

  return connectPromise;
}

function attemptReconnection() {
  connectPromise = null;
  console.log("Disconnected from Comm Service");
  setTimeout(() => {
    console.log("Retrying connection...");
    connectPromise = null;
    connect().catch(() => {
      attemptReconnection();
    });
  }, RETRY_TIMEOUT);
}

client.on('close', () => {
  attemptReconnection();
});

// @TODO: Need to find aa way to also send these messages... ironically
client.on('message', message => {
  const topic = message.topic;
  listeners[topic].foreEach(listener => listener(message.data));
});

function removeListener(type, event, listener) {
  const topic = `${type}:${event}`;
  const index = listeners[topic].indexOf(listener);
  listeners[topic].splice(index, 1);
}

export function onEvent(type, event, listener) {
  const topic = `${type}:${event}`;
  console.log('Topic Message: ' + topic);
  listeners[topic] = listeners[topic] || [];

  return connect()
  .then(() => client.subscribe('protected', topic))
  .then(() => { listeners[topic].push(listener) })
  .then(() => removeListener.bind(null, event, listener));
}

// Clock events
export const onClockEndEvent = onEvent.bind(null, 'clock', 'end');
export const onClockStopEvent = onEvent.bind(null, 'clock', 'stop');
export const onClockTimeEvent = onEvent.bind(null, 'clock', 'time');
export const onClockPrestartEvent = onEvent.bind(null, 'clock', 'prestart');
export const onClockStartEvent = onEvent.bind(null, 'clock', 'start');
export const onClockReloadEvent = onEvent.bind(null, 'clock', 'reload');
export const onClockEndGameEvent = onEvent.bind(null, 'clock', 'endgame');