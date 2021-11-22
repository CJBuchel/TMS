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
	const value = req.body.pass;
	const sql = "UPDATE users SET password = '" + value + "' WHERE name = '" + user + "';";


	db.query(sql, (err, result) => {
		if (err) {
			console.log("User Update error");
			res.send({message: "Error Updaing user (Check logs)"});
			throw err;
		} else {
			console.log(sql);
			console.log(result);
			res.send({message: "Update successful for user [" + user + "]"});
		}
	});
});

// 
// ------------------------ Team getters ---------------------
// 
app.get('/api/teams/get', (req, res) => {
	const sql = "SELECT * FROM fll_teams ORDER BY ranking ASC;";
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

// Add new team
app.post('/api/team/new', (req, res) => {
	console.log("adding team");
	const team_number = req.body.number;
	const team_name = req.body.name;
	const team_affiliation = req.body.aff;

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
				res.send({err: err, message: "Error: [" + team_name + "] already exists"})
			} else {
				if (typeof team_name !== 'undefined') {
					db.query(sql_insert, [team_number, team_name, team_affiliation], (err, result) => {
						if (err) {
							console.log("Error: " + err);
							res.send({err: err, message: "Team insert error"})
						} else {
							console.log("New team: " + team_name);
							res.send({message: "Team [" + team_name + "] added"})
						}
					});
				} else {
					console.log("Found empty row, not posting to database");
				}
			}
		}
	});
});

// New set of teams
app.post('/api/teamset/new', (req, res) => {
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

function changeTeam(team_number, req, res) {
	const original_team = team_number;
	const name = req.body.name;
	const aff = req.body.aff;

	const score1 = req.body.score1;
	const score2 = req.body.score2;
	const score3 = req.body.score3;

	const gp1 = req.body.gp1;
	const gp2 = req.body.gp2;
	const gp3 = req.body.gp3;

	const notes1 = req.body.notes1;
	const notes2 = req.body.notes2;
	const notes3 = req.body.notes3;

	console.log("Team number: " + original_team);

	if (typeof name !== 'undefined') {
		const sql = "UPDATE fll_teams SET team_name = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [name], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof aff !== 'undefined') {
		const sql = "UPDATE fll_teams SET school_name = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [aff], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	// Scores
	if (typeof score1 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_score_1 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [score1], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof score2 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_score_2 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [score2], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof score3 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_score_3 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [score3], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	// GP
	if (typeof gp1 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_gp_1 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [gp1], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof gp2 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_gp_2 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [gp2], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof gp3 !== 'undefined') {
		const sql = "UPDATE fll_teams SET match_gp_3 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [gp3], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	// Notes
	if (typeof notes1 !== 'undefined') {
		const sql = "UPDATE fll_teams SET team_notes_1 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [notes1], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	} else {
		console.log("Notes 1 undefined");
	}

	if (typeof notes2 !== 'undefined') {
		const sql = "UPDATE fll_teams SET team_notes_2 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [notes2], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	if (typeof notes3 !== 'undefined') {
		const sql = "UPDATE fll_teams SET team_notes_3 = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [notes3], (err, result) => {
			console.log(result)
			if (err) { console.log(err); res.send({message: "Error updating team"}); }
		});
	}

	sendEvent("cj_node", "clock:endgame", true);
}

app.post('/api/team/modify', (req, res) => {
	var original_team = req.body.original_team.number;
	const number = req.body.number;

	// Main update section
	if (typeof number !== 'undefined') {
		const sql = "UPDATE fll_teams SET team_number = ? WHERE team_number = '" + original_team + "';";
		db.query(sql, [number], (err, result) => {
			console.log(result)
			if (err) { 
				console.log(err); 
				res.send({message: "Error updating team"}); 
			} else {
				changeTeam(number, req, res);
				updateRanking();
			}
		});
	} else {
		console.log("Team number not changed. Running regular changes");
		changeTeam(original_team, req, res);
		updateRanking();
	}
});

async function updateRanking() {
	const sql = "SELECT * FROM fll_teams ORDER BY ranking ASC;";
	db.query(sql, (err, result) => {
		// console.log(result[0]);
		var teams = [];

		for (const team of result) {
			var scores = [team.match_score_1, team.match_score_2, team.match_score_3];
			scores.sort();
			var highest = scores[0];
			if (highest == null) {
				highest = 0;
			}



			teams.push({name: team.team_name, highest_score: highest, rank: 0});
		}

		for (var i = 0; i < teams.length; i++) {
			var ranking = 1;
			for (var j = 0; j < teams.length; j++) {
				if (teams[j].highest_score > teams[i].highest_score) {
					// teams[i].rank = ranking;
					ranking++;
				}
				
			}

			teams[i].rank = ranking;
		}

		for (const team of teams) {
			db.query("UPDATE fll_teams SET ranking = ? WHERE team_name = ?;", [team.rank, team.name], (err, result) => {
				if (err) {
					console.log(err);
				} else {
					console.log(result);
				}
			}); 
		}

		console.log(teams);
		sendEvent("cj_node", "score:update", "rankings");
	})
}

app.post('/api/teams/updateRanking', (req, res) => {
	updateRanking();
});

// Update team score
app.post('/api/teams/score', (req, res) => {
	console.log("Team score update requested");
	const team_name = req.body.name;
	const rank_number = req.body.rank;
	const team_score = req.body.score;
	const team_gp = req.body.gp;
	const team_notes = req.body.notes;

	if (rank_number < 1 || rank_number > 3) {
		res.send({message: "Unknown rank number"});
	}

	var rank_sql = "";
	var gp_sql = "";
	var notes_sql = "";
	switch (rank_number) {
		case 1:
			rank_sql = "match_score_1";
			gp_sql = "match_gp_1";
			notes_sql = "team_notes_1";
			break;
		
		case 2:
			rank_sql = "match_score_2";
			gp_sql = "match_gp_2";
			notes_sql = "team_notes_2";
			break;
		
		case 3:
			rank_sql = "match_score_3";
			gp_sql = "match_gp_3";
			notes_sql = "team_notes_3";
			break;

		default:
			res.send({message: "Unknown rank number"});
			return;
	}

	console.log("Rank num: '" + rank_number + "' sql: " + rank_sql);

	const sql_team_score = rank_sql + " = '" + team_score + "', ";
	const sql_team_gp = gp_sql + " = '" + team_gp + "', ";
	const sql_team_notes = notes_sql + " = '" + team_notes + "' ";
	
	const sql_get = "SELECT * from fll_teams WHERE team_name = ?;"
	const sql_update = "UPDATE fll_teams SET "+sql_team_score+sql_team_gp+sql_team_notes+" WHERE team_name = ?;";
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
						updateRanking();
					}
				});
			}
		}
	})
});


// 
// ------------------------ Clock ---------------------------------
// 

// Main countdown
var countDownTime = 150; // 150
var prerunTime = 5;
var clockStop = false;


function startCountdown(duration) {
	var start = Date.now(),diff;
	var endgame = false;

	function timer() {
		if (!clockStop) {
			diff = duration - (((Date.now() - start) / 1000) | 0);
	
			console.log(diff);
			sendEvent("cj_node", "clock:time", {time: diff});
	
			if (diff <= 30) {
				if (!endgame) {
					endgame = true;
					sendEvent("cj_node", "clock:endgame", true);
				}
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
	sendEvent("cj_node", "clock:prestart", true);

	function timer() {
		diff = duration - (((Date.now() - start) / 1000) | 0);
		if (!clockStop) {
	
			console.log(diff);
	
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