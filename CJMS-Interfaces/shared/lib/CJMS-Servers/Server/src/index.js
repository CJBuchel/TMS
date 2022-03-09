import express from 'express';
// import * as cjms_db from './api/mysql';
import mongoose from 'mongoose';
mongoose.connect('mongodb://localhost:27017', {
    dbName: 'cjms_database',
    user: 'cjms',
    pass: 'cjms',
    autoCreate: true
});
const PersonSchema = new mongoose.Schema({
    name: { type: String, required: true },
    lastName: { type: String, },
    age: { type: Number }
});
const Person = mongoose.model("PersonData", PersonSchema);
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
