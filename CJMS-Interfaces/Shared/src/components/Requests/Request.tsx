// import * as req_namespaces from "./Namespaces";
import { IEvent } from "@cjms_shared/services";
import { IJudgingSession } from "@cjms_shared/services";
import { IMatch } from "@cjms_shared/services";
import { request_namespaces, ITeamScore, ITeam } from "@cjms_shared/services";
import { ITeamScoreGet } from "@cjms_shared/services/lib/components/InterfaceModels/TeamScore";


export async function CJMS_FETCH_GENERIC_POST(request:RequestInfo, postData:any, noAlert:boolean = false): Promise<Response> {
  console.log(request_namespaces.request_api_location);
  const res:Promise<Response> = await fetch(request, {
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

export async function CLOUD_FETCH_GENERIC_POST(request:RequestInfo, token:string, postData:any): Promise<Response> {
  console.log(request_namespaces.request_api_location);
  const res:Promise<Response> = await fetch(request, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Token': token
    },
    body: JSON.stringify(postData)
  }).then((response:any) => {
    // Return the response in json format
    return response.json();
  }).then((data:any) => {
    // If message from request server
    return data;
  }).catch((error:any) => {
    // Error while trying to post to server
    console.log("Error While Posting");
    console.log(error);
    throw error;
  });

  return res;
}

export async function CLOUD_FETCH_GENERIC_GET(request:any): Promise<Response> {
  return await CJMS_FETCH_GENERIC_GET(request);
}

// Login
export async function CJMS_REQUEST_LOGIN(credentials:any): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_login, credentials);
}

// Clock/Timer
export async function CJMS_POST_TIMER(timerStatus:string): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_timer, {timerState: timerStatus});
}

// Post event data
export async function CJMS_POST_SETUP(event:IEvent): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_setup, event);
}

// Post Score
export async function CJMS_POST_SCORE(teamScore:ITeamScore): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_score, teamScore);
}

// Get Teams
export async function CJMS_REQUEST_TEAMS(noAlert:boolean = false): Promise<ITeam[]> {
  const teamData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_teams, noAlert);
  return teamData.data;
}

// Update Team
export async function CJMS_POST_TEAM_UPDATE(team_number:string, team_update:ITeam): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_team_update, {team: team_number, update: team_update});
}

// Get Matches
export async function CJMS_REQUEST_MATCHES(noAlert:boolean = false): Promise<IMatch[]> {
  const matchData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_matches, noAlert);
  return matchData.data;
}

// Post Match Update
export async function CJMS_POST_MATCH_UPDATE(match_number:string, match_update:IMatch): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_match_update, {match: match_number, update: match_update});
}

// Get Event
export async function CJMS_REQUEST_EVENT(noAlert:boolean = false): Promise<IEvent> {
  const eventData:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, noAlert);
  return eventData.data;
}

// Update Event
export async function CJMS_POST_EVENT_UPDATE(event:IEvent): Promise<Response> {
  return await CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_event_update, event);
}


// Get Judging Sessions
export async function CJMS_REQUEST_JUDGING_SESSIONS(noAlert:boolean = false): Promise<IJudgingSession[]> {
  const judgingSessionData:any = await CJMS_FETCH_GENERIC_POST(request_namespaces.request_fetch_judging_sessions, noAlert);
  return judgingSessionData.data;
}

// 
// Cloud Requests
// 

export async function CLOUD_REQUEST_TOURNAMENTS(): Promise<Response> {
  const request = `${request_namespaces.cloud_api_tournaments}`;
  return await CLOUD_FETCH_GENERIC_GET(request);
}

export async function CLOUD_REQUEST_TEAMS(tournament_id:string): Promise<Response> {
  const request = `${request_namespaces.cloud_api_teams}/${tournament_id}`;
  return await CLOUD_FETCH_GENERIC_GET(request);
}

export async function CLOUD_REQUEST_SCORESHEETS(tournament_id:string): Promise<ITeamScoreGet | undefined> {
  const request = `${request_namespaces.cloud_api_scoresheets}/${tournament_id}`;
  CLOUD_FETCH_GENERIC_GET(request).then(res => {
    console.log(res);
    return res;
  });

  return undefined
}

// export async function CLOUD_POST_SCORESHEET()