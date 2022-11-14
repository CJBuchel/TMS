import { request_namespaces } from "@cjms_shared/services";
export async function CJMS_FETCH_GENERIC_POST(request, postData, noAlert = false) {
    console.log(request_namespaces.request_api_location);
    const controller = new AbortController();
    const res = await fetch(request, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(postData)
    }).then((response) => {
        // Return the response in json format
        return response.json().then((data) => {
            controller.abort();
            if (data.message && !noAlert) {
                alert(data.message);
            }
            return data;
        });
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
    const controller = new AbortController();
    const res = await fetch(request).then((response) => {
        // Return the response in json format
        return response.json().then((data) => {
            controller.abort();
            if (data.message && !noAlert) {
                alert(data.message);
            }
            return data;
        });
    }).catch((error) => {
        // Error while trying to post to server
        console.log("Error While Fetching");
        console.log(error);
        throw error;
    });
    return res;
}
export async function CLOUD_FETCH_GENERIC_POST(request, token, postData) {
    console.log(request);
    const res = await fetch(request, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Token': token
        },
        body: JSON.stringify(postData)
    }).then((response) => {
        // Return the response in json format
        return response.json();
    }).then((data) => {
        // If message from request server
        return data;
    }).catch((error) => {
        // Error while trying to post to server
        console.log("Error While Posting");
        console.log(error);
        throw error;
    });
    return res;
}
export async function CLOUD_FETCH_GENERIC_DELETE(request, token) {
    console.log(request);
    const res = await fetch(request, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Token': token
        }
    }).then((response) => {
        return response;
    }).catch((error) => {
        // Error while trying to post to server
        console.log("Error While Posting");
        console.log(error);
        throw error;
    });
    return res;
}
export async function CLOUD_FETCH_GENERIC_GET(request) {
    return await CJMS_FETCH_GENERIC_GET(request);
}
// Login
export async function CJMS_REQUEST_LOGIN(credentials) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_login, credentials);
}
// Clock/Timer
export async function CJMS_POST_TIMER(timerStatus) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, { timerState: timerStatus });
}
// Post event data
export async function CJMS_POST_SETUP(event) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_setup, event);
}
// Post Score
export async function CJMS_POST_SCORE(team_number, teamScore) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_score, { team_number: team_number, score: teamScore });
}
// Get Teams
export async function CJMS_REQUEST_TEAMS(noAlert = false) {
    const teamData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, noAlert);
    return teamData.data;
}
// Update Team
export async function CJMS_POST_TEAM_UPDATE(team_number, team_update) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_update, { team: team_number, update: team_update });
}
// Get Matches
export async function CJMS_REQUEST_MATCHES(noAlert = false) {
    const matchData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, noAlert);
    return matchData.data;
}
// Post Match Update
export async function CJMS_POST_MATCH_UPDATE(match_number, match_update) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_update, { match: match_number, update: match_update });
}
// Post match create
export async function CJMS_POST_MATCH_CREATE(match) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_create, { match: match });
}
// Post match delete
export async function CJMS_POST_MATCH_DELETE(match) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_delete, { match: match });
}
// Get Event
export async function CJMS_REQUEST_EVENT(noAlert = false) {
    const eventData = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, noAlert);
    return eventData.data;
}
// Update Event
export async function CJMS_POST_EVENT_UPDATE(event) {
    return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_event_update, event);
}
// Get Judging Sessions
export async function CJMS_REQUEST_JUDGING_SESSIONS(noAlert = false) {
    const judgingSessionData = await CJMS_FETCH_GENERIC_POST(request_namespaces.request_fetch_judging_sessions, noAlert);
    return judgingSessionData.data;
}
// 
// Cloud Requests
// 
export async function CLOUD_REQUEST_TOURNAMENTS() {
    const request = `${request_namespaces.cloud_api_tournaments}`;
    return await CLOUD_FETCH_GENERIC_GET(request);
}
export async function CLOUD_REQUEST_TEAMS(tournament_id) {
    const request = `${request_namespaces.cloud_api_teams}/${tournament_id}`;
    return await CLOUD_FETCH_GENERIC_GET(request);
}
export async function CLOUD_REQUEST_SCORESHEETS(tournament_id) {
    const request = `${request_namespaces.cloud_api_scoresheets}/${tournament_id}`;
    return await CLOUD_FETCH_GENERIC_GET(request);
}
export async function CLOUD_POST_SCORESHEET(token, scoresheet) {
    const request = `${request_namespaces.cloud_api_scoresheets}/${scoresheet.tournament_id}`;
    return await CLOUD_FETCH_GENERIC_POST(request, token, scoresheet);
}
export async function CLOUD_DELETE_SCORESHEET(token, tournament_id, scoresheet_id) {
    const request = `${request_namespaces.cloud_api_scoresheets}/${tournament_id}/${scoresheet_id}`;
    return await CLOUD_FETCH_GENERIC_DELETE(request, token);
}
