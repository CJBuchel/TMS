"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.request_fetch_event = exports.request_post_team_score = exports.request_fetch_teams = exports.request_post_purge = exports.request_post_setup = exports.request_post_timer = exports.request_post_login = exports.request_api_location_post = exports.request_api_location_fetch = exports.request_api_location = exports.request_api_port = void 0;
exports.request_api_port = 2121;
if (typeof window !== 'undefined') {
    exports.request_api_location = `http://${window.location.hostname}:${exports.request_api_port.toString()}/cjms_server`;
}
else {
    exports.request_api_location = `/cjms_server`;
}
exports.request_api_location_fetch = `${exports.request_api_location}/fetch`;
exports.request_api_location_post = `${exports.request_api_location}/post`;
// Login
exports.request_post_login = `${exports.request_api_location_post}/login`;
// Clock/Timer
exports.request_post_timer = `${exports.request_api_location_post}/timer`;
// setup
exports.request_post_setup = `${exports.request_api_location_post}/setup`;
exports.request_post_purge = `${exports.request_api_location_post}/purge`;
// Team Database
exports.request_fetch_teams = `${exports.request_api_location_fetch}/teams`;
exports.request_post_team_score = `${exports.request_api_location_post}/teams/score`;
// Event Database
exports.request_fetch_event = `${exports.request_api_location_fetch}/event`;
