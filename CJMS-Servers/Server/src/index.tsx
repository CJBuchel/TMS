import express from 'express';

import mongoose from 'mongoose';
import { Database } from './api/database';
import { RequestServer, Users } from './api/requests';

const cjms_database = new Database();
const cjms_requests = new RequestServer();
cjms_requests.connect();

const cjms_request_users = new Users(cjms_requests);