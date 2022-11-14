"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.request_post_match_delete = exports.request_post_match_create = exports.request_post_match_update = exports.request_post_match_complete = exports.request_post_match_load = exports.request_fetch_matches = exports.request_post_event_update = exports.request_fetch_event = exports.request_fetch_judging_sessions = exports.request_post_team_update = exports.request_post_team_score = exports.request_fetch_teams = exports.request_post_purge = exports.request_post_setup = exports.request_post_timer = exports.request_post_user_update = exports.request_post_user_login = exports.request_api_location_post = exports.request_api_location_fetch = exports.request_api_location = exports.cloud_api_scoresheets = exports.cloud_api_teams = exports.cloud_api_tournaments = exports.cloud_api_location = exports.request_api_port = void 0;
exports.request_api_port = 2121;
// 
// Cloud api's
// 
exports.cloud_api_location = "https://firstaustralia.systems/api";
exports.cloud_api_tournaments = `${exports.cloud_api_location}/tournaments`;
exports.cloud_api_teams = `${exports.cloud_api_location}/team/tournament`;
exports.cloud_api_scoresheets = `${exports.cloud_api_location}/scoresheets`;
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
exports.request_post_team_update = `${exports.request_api_location_post}/team/update`;
// Judging Session Database
exports.request_fetch_judging_sessions = `${exports.request_api_location_fetch}/judging_sessions`;
// Event Database
exports.request_fetch_event = `${exports.request_api_location_fetch}/event`;
exports.request_post_event_update = `${exports.request_api_location}/event/update`; // {team: number, update: ITeam}
// Match Database
exports.request_fetch_matches = `${exports.request_api_location_fetch}/matches`;
exports.request_post_match_load = `${exports.request_api_location_post}/match/load`;
exports.request_post_match_complete = `${exports.request_api_location_post}/match/complete`;
exports.request_post_match_update = `${exports.request_api_location_post}/match/update`; // {match: number, update: IMatch}
exports.request_post_match_create = `${exports.request_api_location_post}/match/create`; // {match: IMatch}
exports.request_post_match_delete = `${exports.request_api_location_post}/match/delete`; // {match: number}
