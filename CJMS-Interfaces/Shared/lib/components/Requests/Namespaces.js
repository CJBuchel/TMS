export const request_api_port = 2121;
export var request_api_location = `http://${window.location.hostname}:${request_api_port.toString()}/api`;
export const request_api_location_fetch = `${request_api_location}/fetch`;
export const request_api_location_post = `${request_api_location}/post`;
// Database getters
export const request_post_login = `${request_api_location_post}/login`;
