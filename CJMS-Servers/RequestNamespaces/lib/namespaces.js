"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.request_post_timer = exports.request_post_login = exports.request_api_location_post = exports.request_api_location_fetch = exports.request_api_location = exports.request_api_port = void 0;
exports.request_api_port = 2121;
exports.request_api_location = `/cjms_server`;
exports.request_api_location_fetch = `${exports.request_api_location}/fetch`;
exports.request_api_location_post = `${exports.request_api_location}/post`;
// Login
exports.request_post_login = `${exports.request_api_location_post}/login`;
// Clock/Timer
exports.request_post_timer = `${exports.request_api_location_post}/timer`;
