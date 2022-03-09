import express from 'express';

import mongoose from 'mongoose';
import { Database } from './api/database';

const cjms_database = new Database();

const app = express();
const port = 2121;

const Test = 5;
export default Test;