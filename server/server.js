// const comm_service = require('./comm_service');

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mysql = require('mysql');
const sendEvent = require('./comm_service');
const { clearInterval } = require('timers');
const { match } = require('assert');

function sleep(ms) {
	const date = Date.now();
	let currDate = null;
	do {
		currDate = Date.now();
	} while (currDate - date < ms);
}


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
	const sql_schedule = "TRUNCATE TABLE fll_teams_schedule;";
	const sql_matches = "TRUNCATE TABLE fll_matches;";
	const sql_users = "TRUNCATE TABLE users;";
	const sql_insert_user = "INSERT INTO users (name, password) VALUES (?,?)";

	db.query(sql_teams, (err, result) => {
		console.log("Teams purge");
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_schedule, (err, result) => {
		console.log("Schedule purge");
		console.log(err);
		// console.log(result);

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_matches, (err, result) => {
		console.log("Matches purge");
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

		if (err) { res.send({message: "Failed to purge database. Check if it exists"}); }
	});

	db.query(sql_insert_user, ["head_referee", "password"], (err, result) => {
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
// ------------------------ Schedule ---------------------
// 

app.get('/api/scheduleSet/get', (req, res) => {
	const sql = "SELECT * FROM fll_teams_schedule ORDER BY id ASC;";
	db.query(sql, (err, result) => {
		// console.log(result);
		console.log("Schedule requested")
		if (err) {
			console.log("Schedule request error");
		} else {
			res.send(result);
		}
	});
});

app.post('/api/schedule/new', (req, res) => {
	console.log("New schedule not implemented yet!");
});

app.post('/api/scheduleSet/new', (req, res) => {
	const schedule_data = req.body.schedule_data;
	const tables = schedule_data.tables;
	const matches = schedule_data.matches;

	// Specific Schedule insert
	for (const match of matches) {
		for (var i = 3; i < match.length; i++) {
			if (typeof match[i] !== 'undefined' && match[i] !== null && match[i] !== '' && match[i] !== ' ') {
				const match_number = match[0];
				const start_time = match[1];
				const end_time = match[2];
				const team_number = match[i];
				const on_table = tables[i-3].table;

				// console.log("Match " + match_number + " table: " + on_table + ", team: " + team_number)
				
				const sql_insert = "INSERT INTO fll_teams_schedule (match_number, start_time, end_time, team_number, on_table) VALUES (?,?,?,?,?);";
				
				// Check if schedule exists
				db.query("SELECT * FROM fll_teams_schedule WHERE match_number = ? AND team_number = ?", [match_number, team_number], (err, result) => {
					if (err) {
						res.send({err: err, message: "Schedule error while trying to grab from table"});
						console.log("DB Select schedule error");
					} else {
						if (result.length > 0) {
							console.log("Error Match [" + match_number + "] With Team [" + team_number + "] already exists");
						} else {
							if (typeof match_number !== 'undefined' && typeof team_number !== 'undefined') {

								// Send Schedule
								db.query(sql_insert, [match_number, start_time, end_time, team_number, on_table], (err, result) => {
									// console.log(result);
									if (err) {
										res.send({err: err, message: "Schedule new error => Get CJ"});
										console.log("DB Create Schedule error");
										console.log(err);
									} else {
										console.log("New Match -> " + "Number: " + match[0] + ", StartTime: " + match[1] + ", EndTime: " + match[2] + ", TeamNumber: " + match[i]  + ", On Table: " + on_table);
									}
								});


							} else {
								console.log("Found empty row, not posting to db");
							}
						}
					}
				});
			}
		}
	}

	// Match insert
	for (const match of matches) {
		var team_number = [];
		var on_table = [];
		for (var i = 3; i < match.length; i++) {
			if (typeof match[i] !== 'undefined' && match[i] !== null && match[i] !== '' && match[i] !== ' ') {
				team_number.push(match[i]);
				on_table.push(tables[i-3].table);
			}
		}

		const sql_insert = "INSERT INTO fll_matches (next_match_number, next_start_time, next_end_time, on_table1, on_table2, next_team1_number, next_team2_number) VALUES (?,?,?,?,?,?,?);";
		db.query(sql_insert, [match[0], match[1], match[2], on_table[0], on_table[1], team_number[0], team_number[1]], (err,result) => {
			if (err) {
				res.send({err: err, message: "Match new error => Get CJ"});
				console.log("DB Create match error");
				console.log(err);
			} else {
				console.log("New match -> " + "Number: " + [match[0] + ", Start time: " + match[1] + ", End time: " + match[2] + ", On table: " + on_table[0] + ", On table: " + on_table[1] + ", team1: " + team_number[0] + ", tem2: " + team_number[1]]);
			}
		});
	}
});

// 
// Matches
// 
app.get('/api/matches/get', (req, res) => {
	const sql = "SELECT * FROM fll_matches ORDER BY next_match_number ASC;";
	db.query(sql, (err, result) => {
		// console.log("Matches Requested");
		if (err) {
			console.log("Match request error");
		} else {
			res.send(result);
		}
	});
});

// 
// ------------------------- Teams ------------------------------
// 

app.get('/api/teams/get', (req, res) => {
	const sql = "SELECT * FROM fll_teams ORDER BY ranking ASC;";
	db.query(sql, (err, result) => {
		// console.log(result);
		// console.log("Teams requested")

		if (err) {
			console.log("Teams request error");
		} else {
			res.send(result);
		}
	});
});

// Add new team
app.post('/api/team/new', (req, res) => {
	console.log("adding team");
	const team_number = req.body.number;
	const team_name = req.body.name;
	const team_affiliation = req.body.aff;

	const sql_get = "SELECT * FROM fll_teams WHERE team_name = ?;";
	const sql_insert = "INSERT INTO fll_teams (team_number, team_name, affiliation) VALUES (?, ?, ?);";
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

	for (const team of teams_data) {
		const team_number = team[0];
		const team_name = team[1];
		const team_aff = team[2];

		const sql_get = "SELECT * FROM fll_teams WHERE team_name = ?;";
		const sql_insert = "INSERT INTO fll_teams (team_number, team_name, affiliation) VALUES (?, ?, ?);";
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
						db.query(sql_insert, [team_number, team_name, team_aff], (err, result) => {
							if (err) {
								console.log("Error: " + err);
								// res.send({err: err, message: "Team insert error"})
							} else {
								console.log("New team: " + team_name);
							}
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
		const sql = "UPDATE fll_teams SET affiliation = ? WHERE team_number = '" + original_team + "';";
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

	// sendEvent("cj_node", "clock:endgame", true);
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
			
			var highest = 0;
			for (var i = 0; i < scores.length; i++) {
				if (scores[i] > highest) {
					highest = scores[i];
				}
			}

			if (highest == null) {
				highest = 0;
			}
			// console.log("team: " + team.team_name + ", highest score: " + scores[0]);

			teams.push({name: team.team_name, highest_score: highest, rank: 0});
		}

		for (var i = 0; i < teams.length; i++) {
			var ranking = 1;
			for (var j = 0; j < teams.length; j++) {
				if (teams[j].highest_score > teams[i].highest_score) {
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
					// console.log(result);
				}
			}); 
		}

		// console.log(teams);
		sendEvent("cj_node", "score:update", "rankings");
	})
}

app.post('/api/teams/updateRanking', (req, res) => {
	updateRanking();
});

// 
// ------------------------- Scoring ------------------------------
// 


// Update team score
app.post('/api/teams/score', (req, res) => {
	console.log("Team score update requested");
	const team_name = req.body.name;
	const rank_number = req.body.rank;
	const team_score = req.body.score;
	const team_gp = req.body.gp;
	const team_notes = req.body.notes;

	if (rank_number < 1 || rank_number > 3) {
		res.send({err: "ranking", message: "Unknown rank number (submit again)"});
		return;
	}

	if (team_score === null || team_score === undefined) {
		res.send({err: "score", message: "Unknown score value (submit again)"});
		return;
	}

	if (team_gp === null || team_gp === undefined ) {
		res.send({err: "gp", message: "Unknown GP value (submit again)"});
		return;
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
			res.send({err: "ranking", message: "Unknown rank number"});
			return;
	}

	console.log("Rank num: '" + rank_number + "' sql: " + rank_sql);

	const sql_team_score = rank_sql + " = '" + team_score + "', ";
	const sql_team_gp = gp_sql + " = '" + team_gp + "', ";
	const sql_team_notes = notes_sql + " = '" + team_notes + "' ";
	
	const sql_matches_get = "SELECT * FROM fll_matches ORDER BY next_match_number ASC;";
	const sql_get = "SELECT * FROM fll_teams WHERE team_name = ?;"
	const sql_update = "UPDATE fll_teams SET "+sql_team_score+sql_team_gp+sql_team_notes+" WHERE team_name = ?;";
	// console.log(sql_get);
	// console.log(sql_update);

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
				res.send({err: "Duplicate Error", message: "Team score already exists! => Get CJ if duplicate issue"})
				console.log("Score exists already");
			} else {
				var team = result[0];
				db.query(sql_update, [team_name], (err, result) => {
					console.log("Updating score");
					// console.log(result);
					if (err) {
						console.log(err);
						res.send({err: err, message: "Error sending score => Get CJ if issue"});
					} else {
						db.query(sql_matches_get, (err, result) => {
							var count = 0;
							console.log("Got some matches");
							for (const match of result) {
								// console.log("Inside match");
								// console.log(match);
								// console.log(team);
								if (match.next_team1_number === team.team_number || match.next_team2_number === team.team_number) {
									count++;
									if (count == rank_number) {
										console.log("Matched count to rank number");
										if (match.next_team1_number === team.team_number) {
											db.query("UPDATE fll_matches SET next_team1_score_submitted = 1 WHERE next_match_number = ?", [match.next_match_number], (err,result) => {
												if (!err) {console.log(result);}
												console.log("Set a submission for team 1");
											});
										}
		
										if (match.next_team2_number === team.team_number) {
											db.query("UPDATE fll_matches SET next_team2_score_submitted = 1 WHERE next_match_number = ?", [match.next_match_number], (err,result) => {
												if (!err) {console.log(result);}
												console.log("Set a submission for team 2");
											});
										}
									}
									console.log("Matched team_match to team in db");
								}

							}
						});
						console.log("Team updated");
						res.send({message: "Team [" + team_name + "] updated"});
						updateRanking();
					}
				});
			}
		}
	})
});


// 
// ------------------------ Time & Scheduling ---------------------
// 
var next_match_number = 1;

function setNextMatch() {
	db.query("UPDATE fll_matches SET complete = ? WHERE next_match_number = ?;", [true, next_match_number], (err, result) => {
		console.log(result);
	});
	next_match_number = next_match_number + 1;
	console.log("Set next match");
}

function setPrevMatch() {
	db.query("UPDATE fll_matches SET complete = ? WHERE next_match_number = ?;", [false, next_match_number], (err, result) => {
		console.log(result);
	});
	db.query("UPDATE fll_matches SET complete = ? WHERE next_match_number = ?;", [false, next_match_number-1], (err, result) => {
		console.log(result);
	});
	next_match_number = next_match_number - 1;
	console.log("set prev match");
}

function setMatch(match) {
	next_match_number = match;
	for (var i = 1; i < next_match_number; i++) {
		db.query("UPDATE fll_matches SET complete = ? WHERE next_match_number = ?;", [false, i], (err, result) => {
			console.log(result);
		});

		db.query("UPDATE fll_matches SET complete = ? WHERE next_match_number = ?;", [true, i], (err, result) => {
			console.log(result);
		});
	}
	console.log("set match");
}

function setRescheduleMatch() {
	db.query("UPDATE fll_matches SET rescheduled = ? WHERE next_match_number = ?;", [true, next_match_number], (err, result) => {
		console.log(result);
	});
	next_match_number = next_match_number + 1;
}

// increment match
app.get('/api/match/next', (req, res) => {
	console.log("ref incremented match");
	setNextMatch();
	res.send({message: "Set match to " + next_match_number});
});

// decrement match
app.get('/api/match/prev', (req, res) => {
	console.log("ref decremented match");
	setPrevMatch();
	res.send({message: "Set match to " + next_match_number});
});

// set match
app.post('/api/match/set', (req, res) => {
	console.log("Match set");
	setMatch(req.body.number);
	res.send({message: "Set match to " + next_match_number});
});

// reschedule match
app.get('/api/match/reschedule', (req, res) => {
	console.log("ref rescheduled match");
	setRescheduleMatch();
	res.send({message: "Rescheduled Match"});
});

async function time_scheduling() {
	var next_match_time = 0; // 24 hour secconds (seconds since 00:00:00)
	var now_time = 0; // 24 hour secconds (seconds since 00:00:00)
	var schedule_ok = false;

	
	// Get which matches have been completed
	function setScheduledMatch() {
		const sql = "SELECT * FROM fll_matches ORDER BY id ASC;";
		db.query(sql, (err, result) => {
			if (err) {
				console.log("Error getting time_schedule");
				console.log(err);
				return;
			} else {
				for (const match of result) {
					if (match.complete == 0 && match.rescheduled == 0) {
						next_match_number = match.next_match_number;
						schedule_ok = true;
						break;
					}
				}
			}
		});
	}
	
	function time_schedule() {

		if (next_match_number !== undefined) {
			setScheduledMatch();
			
			const next_match = "SELECT * FROM fll_matches WHERE next_match_number = ?;";
			db.query(next_match, [next_match_number], (err, result) => {
				if (err) {
					console.log("error");
					console.log(err);
				} else {
					for (const next_match_result of result) { // there should only be one. Just some extra security
						var next_time_string = (next_match_result.next_start_time.substr(0,8));
						var now = new Date();
						var now_time_string = now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds();

						const [hours_next_s, minutes_next_s, seconds_next_s] = next_time_string.split(":");
						const [hours_now_s, minutes_now_s, seconds_now_s] = now_time_string.split(":");

						now_time = (+hours_now_s) * 60 * 60 + (+minutes_now_s) * 60 + (+seconds_now_s);
						next_match_time = (+hours_next_s) * 60 * 60 + (+minutes_next_s) * 60 + (+seconds_next_s);

						const ttl = (next_match_time-now_time);

						sendEvent("cj_node", "schedule:current_time", {now_time: now_time});
						sendEvent("cj_node", "schedule:next_time", {next_match_time: next_match_time});
						sendEvent("cj_node", "schedule:ttl", {time: ttl});
						sendEvent("cj_node", "schedule:next_match", {next_match: next_match_number});
					}
				}
			});
		} else {
			console.log("Schedule Timing error");

		}
	}

	time_schedule();
	setInterval(time_schedule, 1000);
}


// 
// ------------------------ Clock ---------------------------------
// 

// Main countdown
var countDownTime = 150; // 150
var prerunTime = 5;
var clockStop = false;
var existingClock = false;


function startCountdown(duration) {
	if (!existingClock) {
		existingClock = true;

		setNextMatch();
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
					existingClock = false;
					console.log("Stopping counter");
					sendEvent("cj_node", "clock:end", true);
					clearInterval(this)
				}
			} else {
				existingClock = false;
				sendEvent("cj_node", "clock:stop", true);
				clearInterval(this)
			}
		}
	
		timer();
		setInterval(timer, 1000);
	}
}

function startPrerun(duration) {
	if (!existingClock) {
		existingClock = true;
		var start = Date.now(),diff;
		var stop = false;
		sendEvent("cj_node", "clock:prestart", true);
	
		function timer() {
			diff = duration - (((Date.now() - start) / 1000) | 0);
			if (!clockStop) {
		
				console.log(diff);
		
				sendEvent("cj_node", "clock:time", {time: diff});
		
				if (diff <= 0 || clockStop) {
					existingClock = false;
					startCountdown(countDownTime);
					sendEvent("cj_node", "clock:start", true);
					clearInterval(this)
				}
			} else {
				existingClock = false;
				sendEvent("cj_node", "clock:stop", true);
				clearInterval(this)
			}
		}
	
		timer();
		setInterval(timer, 1000);
	}
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
	setPrevMatch();
});

// reload
app.post('/api/clock/reload', (req, res) => {
	clockStop = true;
	console.log("Timer set to reload");
	sendEvent("cj_node", "clock:reload", true);
});

time_scheduling();

app.listen(3001, () => {
	console.log('running on port 3001');
});