var MClient = require("mhub").MClient;

var client = new MClient("ws://localhost:13900");

// 
// ----------------- Sender Event ---------------------
// 

let loginPromise = null;
function login() {
	if (!loginPromise) {
		loginPromise = Promise.resolve(client.connect())
		.then(() => client.login("cj_fss", "fss"));
	}

	return loginPromise;
}


// Main send event
function sendEvent(node, topic, e) {
	return login().then(() => client.publish(node, topic, e));
}

// Main senders for Time
function sendClockTimeEvent(e) {
	return sendEvent("cj_node", "clock:time", e);
}

function sendClockStartEvent(e) {
	return sendEvent("cj_node", "clock:start", e);
}

function sendClockStopEvent(e) {
	return sendEvent("cj_node", "clock:stop", e);
}

function sendClockEndgameEvent(e) {
	return sendEvent("cj_node", "clock:endgame", e);
}

function sendClockEndEvent(e) {
	return sendEvent("cj_node", "clock:end", e);
}

function sendClockPrestartEvent(e) {
	return sendEvent("cj_node", "clock:prestart", e);
}

function sendClockReload(e) {
	return sendEvent("cj_node", "clock:reload", e);
}

module.exports = sendEvent;
// exports.sendEvent = function(node, topic, e) {return sendEvent(node, topic, e)}