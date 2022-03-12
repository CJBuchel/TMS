import * as req_namespaces from "./Namespaces";

export async function CJMS_FETCH_GENERIC_POST(request:RequestInfo, postData:any): Promise<Response> {
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
    if (data.message) {
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
export async function CJMS_FETCH_GENERIC_GET(request:any): Promise<Response> {
  const res:any = await fetch(request).then((response) => {
    // Return the response in json format
    return response.json();
  }).then((data:any) => {
    // If message from request server
    if (data.message) {
      alert(data.message);
    }
    return data;
  }).catch((error:any) => {
    // Error while trying to post to server
    console.log("Error While Fetching");
    console.log(error);
    throw error;
  });

  return res.json();
}

export async function CJMS_REQUEST_LOGIN(credentials:any): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(req_namespaces.request_post_login, credentials);
}