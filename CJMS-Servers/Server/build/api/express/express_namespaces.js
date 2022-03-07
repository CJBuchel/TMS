"use strict";
// 
// Namespaces / API naming scheme
// 
Object.defineProperty(exports, "__esModule", { value: true });
exports.express_comms_set_clock_reload = exports.express_comms_set_clock_stop = exports.express_comms_set_clock_start = exports.express_comms_set_clock_prestart = exports.express_comms_set_clock = exports.express_comms_set = exports.express_database_new_teams = exports.express_database_new_team = exports.express_database_new_judging_schedule = exports.express_database_new_match_schedule = exports.express_database_get_teams = exports.express_database_get_matches = exports.express_database_get_judging_schedule = exports.express_database_get_match_schedule = exports.express_database_get_login = exports.express_database_set_match = exports.express_database_set_team_score = exports.express_database_set_update_rankings = exports.express_database_set_team = exports.express_database_set_reschedule_match = exports.express_database_set_prev_match = exports.express_database_set_next_match = exports.express_database_set_user = exports.express_database_set_purge = exports.express_database_new = exports.express_database_set = exports.express_database_get = exports.express_comms = exports.express_database = exports.base_express_string = exports.server_port = void 0;
// Base
exports.server_port = 2121;
exports.base_express_string = '/api/express';
exports.express_database = `${exports.base_express_string}/database`;
exports.express_comms = `${exports.base_express_string}/comms`;
// 
// --------------- Database
// 
exports.express_database_get = `${exports.express_database}/get`;
exports.express_database_set = `${exports.express_database}/set`;
exports.express_database_new = `${exports.express_database}/new`;
// Database sets
exports.express_database_set_purge = `${exports.express_database_set}/purge`;
exports.express_database_set_user = `${exports.express_database_set}/user`;
exports.express_database_set_next_match = `${exports.express_database_set}/next_match`;
exports.express_database_set_prev_match = `${exports.express_database_set}/next_match`;
exports.express_database_set_reschedule_match = `${exports.express_database_set}/reschedule_match`;
exports.express_database_set_team = `${exports.express_database_set}/team`;
exports.express_database_set_update_rankings = `${exports.express_database_set}/update_rankings`;
exports.express_database_set_team_score = `${exports.express_database_set}/team_score`;
exports.express_database_set_match = `${exports.express_database_set}/match`;
// Database gets
exports.express_database_get_login = `${exports.express_database_get}/login`;
exports.express_database_get_match_schedule = `${exports.express_database_get}/match_schedule`;
exports.express_database_get_judging_schedule = `${exports.express_database_get}/judging_schedule`;
exports.express_database_get_matches = `${exports.express_database_get}/matches`;
exports.express_database_get_teams = `${exports.express_database_get}/teams`;
// Database new
exports.express_database_new_match_schedule = `${exports.express_database_new}/match_schedule`;
exports.express_database_new_judging_schedule = `${exports.express_database_set}/judging_schedule`;
exports.express_database_new_team = `${exports.express_database_new}/team`;
exports.express_database_new_teams = `${exports.express_database_new}/teams`;
// 
// ------------------- Comms (Not many things are server side for comms other than clock)
// 
exports.express_comms_set = `${exports.express_comms}/set`;
exports.express_comms_set_clock = `${exports.express_comms_set}/clock`;
exports.express_comms_set_clock_prestart = `${exports.express_comms_set_clock}/prestart`;
exports.express_comms_set_clock_start = `${exports.express_comms_set_clock}/start`;
exports.express_comms_set_clock_stop = `${exports.express_comms_set_clock}/stop`;
exports.express_comms_set_clock_reload = `${exports.express_comms_set_clock}/reload`;
