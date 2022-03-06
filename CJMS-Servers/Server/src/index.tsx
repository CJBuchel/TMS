import express from 'express';
import { DatabaseConnection } from './api/db';

const app = express();
const port = 2121;

let cjms_db = new DatabaseConnection();
cjms_db.connect();

// app.listen(port, () => {
//   console.log(`Server Running on port ${port}`);
// });