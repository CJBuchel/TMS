import express from 'express';

import mongoose from 'mongoose';
import { Database } from './api/database';
import { Requests } from './api/requests';

const cjms_database = new Database();
const cjms_requests = new Requests();