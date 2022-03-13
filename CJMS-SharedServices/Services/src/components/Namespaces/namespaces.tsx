export const request_api_port = 2121;

export var request_api_location;
if (typeof window !== 'undefined') {
  request_api_location = `http://${window.location.hostname}:${request_api_port.toString()}/cjms_server`;
} else {
  request_api_location = `/cjms_server`;
}

export const request_api_location_fetch = `${request_api_location}/fetch`;
export const request_api_location_post = `${request_api_location}/post`;

// Login
export const request_post_login = `${request_api_location_post}/login`;

// Clock/Timer
export const request_post_timer = `${request_api_location_post}/timer`;