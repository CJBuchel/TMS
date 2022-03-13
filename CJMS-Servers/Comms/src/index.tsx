import * as http from "http";
import "source-map-support/register";
import * as ws from "ws";

// const dotenv = require('dotenv');
// dotenv.config();

import {
  HeaderStore,
  Hub,
  log,
  LogLevel,
  PlainAuthenticator,
  WSConnection,
} from "mhub";

// Setup the main hub for communication (designated by cjms_node)
async function createHub(): Promise<Hub> {
  const auth = new PlainAuthenticator();
  const hub = new Hub(auth);
  auth.setUser("cjms", `${process.env.REACT_APP_PASSWORD_KEY}`);
  console.log("Password: " + process.env.REACT_APP_PASSWORD_KEY);
  hub.setRights({
    // Guests
    "": {
      subscribe: true,
      publish: false
    },
    
    admin: true, // allow everything
    cjms: true, // allow everything
  });

  // Nodes
  const cjms_node = new HeaderStore("cjms_node");

  hub.add(cjms_node);

  await hub.init();
  return hub;
}

// Startup websocket & http server listening
async function startServer(hub:Hub): Promise<void> {
  const httpServer = http.createServer();
  const wss = new ws.Server({server: httpServer});
  let connectionId = 0;
  wss.on(
    "connection",
    (conn: ws) => new WSConnection(hub, conn, "websocket" + connectionId++)
  );

  const port = 2122;
  await new Promise((resolve, reject) => {
    wss.once("error", (err) => {
      console.log(err);
      reject(err);
    });

    httpServer.listen(port, (): void => {
      log.info("Websocket Server started on: " + port);
    });
  });
}

async function Server(): Promise<void> {
  log.logLevel = LogLevel.Debug;
  log.onMessage = (msg:string) => {
    console.log(msg);
  }

  const hub = await createHub();
  await startServer(hub);
  log.info("Comm Server Active");
}

function die(fmt: string, ...args: any[]): void {
  log.fatal(fmt, ...args);
  process.exit(1);
}

// Startup the Comm Server
Server().catch((err) => die("Comm Server Crashed!", err));