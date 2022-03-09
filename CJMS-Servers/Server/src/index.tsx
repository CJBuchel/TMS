import express from 'express';

import mongoose from 'mongoose';
import { Database } from './api/database/database';

const cjms_database = new Database();

const app = express();
const port = 2121;

const Test = 5;
export default Test;

// var response = db.query(cjms_db.queryScripts.sql_get_users);
// if (response.results != null) {
//   console.log("Response");
//   console.log(response.results);
// }

// cjms_db.get_connection().query(cjms_db_api.queryScripts.get_sql_update_user("password", "testing", "user", "admin"), (err:any, result:any) => {
//   console.log(err);
// });

// cjms_db.query(cjms_db_api.queryScripts.get_sql_update_user("password", "testing", "user", "admin"));

// app.listen(port, () => {
//   console.log(`Server Running on port ${port}`);
// });