const express = require('express');
const app = express();
const mysql = require('mysql');

const db = mysql.createPool({
	host: 'localhost',
	user: 'fss',
	password: 'fss',
	database: 'fss_fll_database'
});

app.get('/', (req, res) => {
	res.send("Hello world");
});

app.listen(3001, () => {
	console.log('running on port 3001');
});