// const comm_service = require('./comm_service');

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mysql = require('mysql');
const sendEvent = require('./comm_service');
const { clearInterval } = require('timers');


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

// 
// ------------------------- Main Control -----------------------
// 
app.use('/api/database/purge', (req, res) => {
	const sql_teams = "TRUNCATE TABLE fll_teams;";
	const sql_users = "TRUNCATE TABLE users;";
	const sql_insert_user = "INSERT INTO users (name, password) VALUES (?,?)";

	db.query(sql_teams, (err, result) => {
		console.log("Teams purge");
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_users, (err, result) => {
		console.log("Users purge");
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_insert_user,["admin", "password"] , (err, result) => {
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_insert_user, ["scorekeeper", "password"], (err, result) => {
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_insert_user, ["referee", "password"], (err, result) => {
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); } else {
			res.send({message: "Purged teams, and reset password to default 'password'"});
		}
	});
});


// 
// ------------------------- Login ----------------------------
// 

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
// ------------------------ Team getters ---------------------
// 
app.get('/api/teams/get', (req, res) => {
	const sql = "SELECT * FROM fll_teams ORDER BY ranking ASC";
	db.query(sql, (err, result) => {
		// console.log(result);
		console.log("Team request from db")

		if (err) {
			console.log("Teams get error");
		} else {
			res.send(result);
		}
	});
});


// 
// -------------------------Scoring ------------------------------
// 

// New team
app.post('/api/teams/new', (req, res) => {
	const teams_data = req.body.teams_data;

	for (const team of teams_data.data) {
		const team_number = team[0];
		const team_name = team[1];
		const team_school = team[2];

		const sql_get = "SELECT * FROM fll_teams WHERE team_name = ?;";
		const sql_insert = "INSERT INTO fll_teams (team_number, team_name, school_name) VALUES (?, ?, ?);";
		db.query(sql_get, [team_name], (err, result) => {
	
			if (err) {
				res.send({err: err, message: "Team new error => Get CJ"});
				console.log("DB Team create error");
			} else {
				if (result.length > 0) {
					// res.send("Error Team/Teams already exists. Check server log for detail");
					console.log("Error Team [" + team_name + "] already exists");
				} else {
					if (typeof team_name !== 'undefined') {
						db.query(sql_insert, [team_number, team_name, team_school], (err, result) => {
							if (err) {
								console.log("Error: " + err);
								// res.send({err: err, message: "Team insert error"})
							}
							console.log("New team: " + team_name);
						});
					} else {
						console.log("Found empty row, not posting to database");
						
						// console.log()
					}
				}
			}
		});
	}
});

// Update team score
app.post('/api/teams/score', (req, res) => {
	console.log("Team score update requested");
	const team_name = req.body.name;
	const rank_number = req.body.rank;
	const team_score = req.body.score;

	if (rank_number < 1 || rank_number > 3) {
		res.send({message: "Unknown rank number"});
	}

	var rank_sql = "";
	switch (rank_number) {
		case 1:
			rank_sql = "match_score_1";
			break;
		
		case 2:
			rank_sql = "match_score_2";
			break;
		
		case 3:
			rank_sql = "match_score_3";
			break;

		default:
			res.send({message: "Unknown rank number"});
			return;
	}

	console.log("Rank num: '" + rank_number + "' sql: " + rank_sql);

	const sql_get = "SELECT * from fll_teams WHERE team_name = ?;"
	const sql_update = "UPDATE fll_teams SET " + rank_sql + " = '" + team_score + "' WHERE team_name = ?;";
	console.log(sql_get);
	console.log(sql_update);

	db.query(sql_get, [team_name], (err, result) => {
		console.log("Checking existing scores")
		// console.log(result);
		var score_exists = false;
		switch (rank_number) {
			case 1:
				if (result[0].match_score_1) {
					score_exists = true;
				}
				break;
			case 2:
				if (result[0].match_score_2) {
					score_exists = true;
				}
				break;
			case 3:
				if (result[0].match_score_3) {
					score_exists = true;
				}
				break;
		}
		if (err) {
			console.log(err);
			res.send({err: err, message: err});
		} else {
			console.log("No error. Updating score");
			// console.log(result.data.length);
			if (score_exists) {
				res.send({message: "Team score already exists! => Get CJ if duplicate issue"})
				console.log("Score exists already");
			} else {
				db.query(sql_update, [team_name], (err, result) => {
					console.log("Updating score");
					console.log(result);
					if (err) {
						console.log(err);
						res.send({err: err, message: "Error sending score => Get CJ if issue"});
					} else {
						console.log("Team updated");
						res.send({err: err, message: "Team [" + team_name + "] updated"});
					}
				});
			}
		}
	})

})


// 
// ------------------------ Clock ---------------------------------
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