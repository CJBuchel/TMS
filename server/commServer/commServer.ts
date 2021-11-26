import * as http from "http";
import "source-map-support/register";
import * as ws from "ws";

// Replace ".." with "mhub" in your own programs
import {
	HeaderStore,
	Hub,
	log,
	LogLevel,
	PlainAuthenticator,
	WSConnection,
} from "mhub";

async function createHub(): Promise<Hub> {
	const auth = new PlainAuthenticator();

	// Create a hub
	const hub = new Hub(auth);

	auth.setUser("cj_fss", "fss");
	hub.setRights({
		"": {
			// Anonymous/guest
			subscribe: true,
			publish: false,
		},
		admin: true, // allow everything
		cj_fss: true,
	});

	const cj_node = new HeaderStore("cj_node");
	hub.add(cj_node);

	// Initialize nodes (e.g. load persistent messages from disk)
	await hub.init();

	return hub;
}

async function startWebsocketServer(hub: Hub): Promise<void> {
	// Create transports to the server, in this case a websocket server.
	// See `nodeserver.ts` for more examples, including https and plain TCP.
	// You can use the same `httpServer` for attaching to e.g. your Express API.
	// You can also use a custom path for the websocket.
	const httpServer = http.createServer();
	const wss = new ws.Server({ server: httpServer });

	let connectionId = 0;
	wss.on(
		"connection",
		(conn: ws) => new WSConnection(hub, conn, "websocket" + connectionId++)
	);

	const port = 13900;
	await new Promise((resolve, reject) => {
		wss.once("error", (err) => {
			console.log(err);
			reject(err);
		});
		httpServer.listen(port, (): void => {
			log.info(`WebSocket Server started on port ${port}`);
			resolve(port);
		});
	});
}

async function main(): Promise<void> {
	// Configure logging (optional)
	log.logLevel = LogLevel.Info;
	log.onMessage = (msg: string) => {
		console.log(msg); // tslint:disable-line:no-console
	};

	const hub = await createHub();
	await startWebsocketServer(hub);

	log.info("Comm Server Active");
	log.info("using the websocket connection.");
	log.info("Press Ctrl-C to stop the server.");
}

function die(fmt: string, ...args: any[]): void {
	log.fatal(fmt, ...args);
	process.exit(1);
}

main().catch((err) => die("main crashed", err));