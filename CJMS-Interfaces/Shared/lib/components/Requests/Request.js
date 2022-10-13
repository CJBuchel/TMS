import { request_namespaces } from "@cjms_shared/services";
// const server_location = `http://${window.location.hostname}:${request_namespaces.request_api_port.toString()}`;
export async function CJMS_FETCH_GENERIC_POST(request, postData, noAlert = false) {
    console.log(request_namespaces.request_api_location);
    const res = await fetch(request, {
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
        if (data.message && !noAlert) {
            alert(data.message);
        }
        return data;
    }).catch((error) => {
        // Error while trying to post to server
        console.log("Error While Posting");
        console.log(error);
        throw error;
    });
    return res;
}
// Returns data as json
export async function CJMS_FETCH_GENERIC_GET(request, noAlert = false) {
    const res = await fetch(request).then((response) => {
        // Return the response in json format
        return response.json();
    }).then((data) => {
        // If message from request server
        if (data.message && !noAlert) {
            alert(data.message);
        }
        return data;
    }).catch((error) => {
        // Error while trying to post to server
        console.log("Error While Fetching");
        console.log(error);
        throw error;
    });
    return res;
}
// Login
export async function CJMS_REQUEST_LOGIN(credentials) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_login, credentials);
}
// Clock/Timer
export async function CJMS_POST_TIMER(timerStatus) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, { timerState: timerStatus });
}
// Post Score
export async function CJMS_POST_SCORE(teamScore) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_score, teamScore);
}
// Get Teams
export async function CJMS_REQUEST_TEAMS(noAlert = false) {
    const teamData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, noAlert);
    return teamData.data;
}
// Get Matches
export async function CJMS_REQUEST_MATCHES(noAlert = false) {
    const matchData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, noAlert);
    return matchData.data;
}
// Get Event
export async function CJMS_REQUEST_EVENT(noAlert = false) {
    const eventData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, noAlert);
    return eventData.data;
}
// Get Judging Sessions
export async function CJMS_REQUEST_JUDGING_SESSIONS(noAlert = false) {
    const judgingSessionData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_judging_sessions, noAlert);
    return judgingSessionData.data;
}
