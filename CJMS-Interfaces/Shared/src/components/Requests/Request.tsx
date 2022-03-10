import * as req_namespaces from "./Namespaces";

export async function CJMS_FETCH_GENERIC_POST(request:RequestInfo, postData:any) {
  const response = await fetch(request, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(postData)
  }).then((response) => {
    // Return the response in json format
    return response.json();
  }).then((data) => {
    // If message from request server
    if (data.message) {
      alert(data.message);
    }
  }).catch((error) => {
    // Error while trying to post to server
    console.log("Error While Posting");
    throw error;
  });

  return response;
}

// Returns data as json
export async function CJMS_FETCH_GENERIC_GET(request:any): Promise<RequestInfo> {
  const res:any = await fetch(request).then((response) => {
    // Return the response in json format
    return response.json();
  }).then((data) => {
    // If message from request server
    if (data.message) {
      alert(data.message);
    }
  }).catch((error) => {
    // Error while trying to post to server
    console.log("Error While Posting");
    throw error;
  });

  return res.json();
}

export async function CJMS_REQUEST_LOGIN(credentials:any): Promise<RequestInfo> {
  const res:any = await CJMS_FETCH_GENERIC_POST(req_namespaces.request_post_login, credentials);
  return res;
}