import express from 'express';
import mongoose from 'mongoose';
import { comm_service } from '@cjms_shared/services';
import { Database } from './api/database';
import { RequestServer, Users, Timer, Setup, Teams, Event, Matches } from './api/requests'
import { TeamModel } from './api/database/models/Team';

const cjms_database = new Database();
const cjms_requests = new RequestServer();
cjms_requests.connect();

// Main Requests
const cjms_request_users = new Users(cjms_requests);
const cjms_request_timer = new Timer(cjms_requests);
const cjms_request_setup = new Setup(cjms_requests);
const cjms_request_teams = new Teams(cjms_requests);
const cjms_request_event = new Event(cjms_requests);
const cjms_request_matches = new Matches(cjms_requests);

// Test
// var r = 0
// setInterval(async () => {
//   const update = {
//     $push: {scores: {
//       roundIndex: 0,
//       score: 50+r
//     }}
//   };
//   const filter = { team_name: 'Orion' };
//   let team = await TeamModel.findOneAndUpdate(filter, update);
//   r++;
//   comm_service.senders.sendTeamUpdateEvent('newScore');
// }, 1000);