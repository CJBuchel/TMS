import express from 'express';
import * as cjms_db from './api/mysql';

const app = express();
const port = 2121;

let db = new cjms_db.db.Database();
db.connect();

var response = db.query(cjms_db.queryScripts.sql_get_users);
if (response.results != null) {
  console.log("Response");
  console.log(response.results);
}

// cjms_db.get_connection().query(cjms_db_api.queryScripts.get_sql_update_user("password", "testing", "user", "admin"), (err:any, result:any) => {
//   console.log(err);
// });

// cjms_db.query(cjms_db_api.queryScripts.get_sql_update_user("password", "testing", "user", "admin"));

// app.listen(port, () => {
//   console.log(`Server Running on port ${port}`);
// });