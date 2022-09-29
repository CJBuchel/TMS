// import * as req_namespaces from "./Namespaces";
import { request_namespaces } from "@cjms_shared/services";
// const server_location = `http://${window.location.hostname}:${request_namespaces.request_api_port.toString()}`;

export async function CJMS_FETCH_GENERIC_POST(request:RequestInfo, postData:any, noAlert:boolean = false): Promise<Response> {
  console.log(request_namespaces.request_api_location);
  const res:any = await fetch(request, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(postData)
  }).then((response:any) => {
    // Return the response in json format
    return response.json();
  }).then((data:any) => {
    // If message from request server
    if (data.message && !noAlert) {
      alert(data.message);
    }
    return data;
  }).catch((error:any) => {
    // Error while trying to post to server
    console.log("Error While Posting");
    console.log(error);
    throw error;
  });

  return res;
}

// Returns data as json
export async function CJMS_FETCH_GENERIC_GET(request:any, noAlert:boolean = false): Promise<Response> {
  const res:Promise<Response> = await fetch(request).then((response) => {
    // Return the response in json format
    return response.json();
  }).then((data:any) => {
    // If message from request server
    if (data.message && !noAlert) {
      alert(data.message);
    }
    return data;
  }).catch((error:any) => {
    // Error while trying to post to server
    console.log("Error While Fetching");
    console.log(error);
    throw error;
  });

  return res;
}

// Login
export async function CJMS_REQUEST_LOGIN(credentials:any): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_login, credentials);
}

// Clock/Timer
export async function CJMS_REQUEST_TIMER(timerStatus:string): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, timerStatus);
}