import express from 'express';
import mongoose from 'mongoose';
import { Database } from './api/database';
import { RequestServer, Users, Timer, Setup } from './api/requests'

const cjms_database = new Database();
const cjms_requests = new RequestServer();
cjms_requests.connect();

// Main Requests
const cjms_request_users = new Users(cjms_requests);
const cjms_request_timer = new Timer(cjms_requests);
const cjms_request_setup = new Setup(cjms_requests);