import MHubClient from "mhub/dist/src/browserclient";

var client = new MHubClient("ws://localhost:13900");

let loginPromise = null;
function login() {
	if (!loginPromise) {
		loginPromise = Promise.resolve(client.connect())
		.then(() => client.login("cj_fss", "fss"));
	}

	return loginPromise;
}

// exports.sendTimeEvent = e => {
// 	return login().then(() => client.publish('clock', 'clock:time', "No Time Like the present"));
// }

function sendTimeEvent(e) {
	return login().then(() => client.publish('cj_node', 'clock:time', e));
}

export default sendTimeEvent;

// client.on("message", function(message) {
// 	console.log(message.topic, message.data, message.headers);
// });


// client.connect().then(function() {
// 	client.login("someUser", "somePassword");
// 	client.subscribe("default", "my:"); // or e.g. client.subscribe("blib", "my:*");
// 	client.publish("default", "my:topic", 42, { some: "header" });
// });