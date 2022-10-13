"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.request_post_match_update = exports.request_post_match_complete = exports.request_post_match_load = exports.request_fetch_matches = exports.request_fetch_event = exports.request_fetch_judging_sessions = exports.request_post_team_score = exports.request_fetch_teams = exports.request_post_purge = exports.request_post_setup = exports.request_post_timer = exports.request_post_user_update = exports.request_post_user_login = exports.request_api_location_post = exports.request_api_location_fetch = exports.request_api_location = exports.request_api_port = void 0;
exports.request_api_port = 2121;
if (typeof window !== 'undefined') {
    exports.request_api_location = `http://${window.location.hostname}:${exports.request_api_port.toString()}/cjms_server`;
}
else {
    exports.request_api_location = `/cjms_server`;
}
exports.request_api_location_fetch = `${exports.request_api_location}/fetch`;
exports.request_api_location_post = `${exports.request_api_location}/post`;
// Users
exports.request_post_user_login = `${exports.request_api_location_post}/user/login`;
exports.request_post_user_update = `${exports.request_api_location_post}/user/update`;
// Clock/Timer
exports.request_post_timer = `${exports.request_api_location_post}/timer`;
// Setup
exports.request_post_setup = `${exports.request_api_location_post}/setup`;
exports.request_post_purge = `${exports.request_api_location_post}/purge`;
// Team Database
exports.request_fetch_teams = `${exports.request_api_location_fetch}/teams`;
exports.request_post_team_score = `${exports.request_api_location_post}/teams/score`;
// Judging Session Database
exports.request_fetch_judging_sessions = `${exports.request_api_location_fetch}/judging_sessions`;
// Event Database
exports.request_fetch_event = `${exports.request_api_location_fetch}/event`;
// Match Database
exports.request_fetch_matches = `${exports.request_api_location_fetch}/matches`;
exports.request_post_match_load = `${exports.request_api_location_post}/match/load`;
exports.request_post_match_complete = `${exports.request_api_location_post}/match/complete`;
exports.request_post_match_update = `${exports.request_api_location_post}/match/update`; // {match: number, update: {data...}}
