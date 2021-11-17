const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const mysql = require('mysql');

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

app.listen(3001, () => {
	console.log('running on port 3001');
});