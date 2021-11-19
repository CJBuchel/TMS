// const comm_service = require('./comm_service');

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mysql = require('mysql');
const sendEvent = require('./comm_service');
const getEvent = require('./comm_receiver');
const { clear } = require('console');
const { clearInterval } = require('timers');

const user_table = "users";
const fll_teams_table = "fll_teams";

const db = mysql.createConnection({
	host: 'localhost',
	user: 'fss',
	password: 'fss',
	database: 'fss_fll_database',
	insecureAuth: true
});

db.connect(function(err) {
	if (err) {
		console.log("Database connection error");
		throw err;
	}
	console.log("Connected!");
});

app.use(cors());
app.use(express.json());
app.use(bodyParser.urlencoded({
  extended: true
}));

app.use('/api/login', (req, res) => {
	const username = req.body.user;
	const password = req.body.password;

	const sql = "SELECT * FROM users WHERE name = ? AND password = ?";
	db.query(sql, [username, password], (err, result) => {
		if (err) {
			res.send({err: err});
			console.log("User Update error");
		} else {
			if (result.length > 0) {
				res.send({
					token: "connection-" + Math.random()
				});
			} else {
				res.send({message: "Wrong username/password"});
			}

			console.log(sql);
			console.log(result);
		}
	});
});

app.post('/api/updateUser', (req, res) => {
	const user = req.body.user;
	const value = req.body.password;
	const sql = "UPDATE users SET password = '" + value + "' WHERE name = '" + user + "';";


	db.query(sql, (err, result) => {
		console.log("User: " + user);
		console.log("Pass: " + value);
		if (err) {
			console.log("User Update error");
			throw err;
		} else {
			console.log(sql);
			console.log(result);
		}
	});
});

// 
// Clock
// 

// Main countdown
var countDownTime = 150; // 150
var prerunTime = 5;
var clockStop = false;


function startCountdown(duration) {
	var start = Date.now(),diff;

	function timer() {
		if (!clockStop) {
			diff = duration - (((Date.now() - start) / 1000) | 0);
	
			console.log(diff);
			sendEvent("cj_node", "clock:time", {time: diff});
	
			if (diff <= 30) {
				sendEvent("cj_node", "clock:endgame", true);
			}
	
			if (diff <= 0) {
				console.log("Stopping counter");
				sendEvent("cj_node", "clock:end", true);
				clearInterval(this)
			}
		} else {
			sendEvent("cj_node", "clock:stop", true);
			clearInterval(this)
		}
	}

	timer();
	setInterval(timer, 1000);
}

function startPrerun(duration) {
	var start = Date.now(),diff;
	var stop = false;

	function timer() {
		diff = duration - (((Date.now() - start) / 1000) | 0);
		if (!clockStop) {
	
			console.log(diff);
	
			sendEvent("cj_node", "clock:prestart", true);
			sendEvent("cj_node", "clock:time", {time: diff});
	
			if (diff <= 0 || clockStop) {
				startCountdown(countDownTime);
				sendEvent("cj_node", "clock:start", true);
				clearInterval(this)
			}
		} else {
			sendEvent("cj_node", "clock:stop", true);
			clearInterval(this)
		}
	}

	timer();
	setInterval(timer, 1000);
}


// prestart
app.post('/api/clock/prestart', (req, res) => {
	console.log("Timer set to prestart");
	clockStop = false;
	sendEvent("cj_node", "clock:prestart", true);
	startPrerun(prerunTime);
});

// start
app.post('/api/clock/start', (req, res) => {
	console.log("Timer set to start");
	clockStop = false;
	sendEvent("cj_node", "clock:start", true);
	startCountdown(countDownTime);
});

// stop/abort
app.post('/api/clock/stop', (req, res) => {
	clockStop = true;
	console.log("Timer set to stop");

	sendEvent("cj_node", "clock:stop", true);
});

// reload
app.post('/api/clock/reload', (req, res) => {
	clockStop = true;
	console.log("Timer set to reload");
	sendEvent("cj_node", "clock:reload", true);
});


app.listen(3001, () => {
	console.log('running on port 3001');
});