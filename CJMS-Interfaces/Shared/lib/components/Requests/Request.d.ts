import { TeamScoreContainer } from "@cjms_shared/services";
export declare function CJMS_FETCH_GENERIC_POST(request: RequestInfo, postData: any, noAlert?: boolean): Promise<Response>;
export declare function CJMS_FETCH_GENERIC_GET(request: any, noAlert?: boolean): Promise<Response>;
export declare function CJMS_REQUEST_LOGIN(credentials: any): Promise<Response>;
export declare function CJMS_POST_TIMER(timerStatus: string): Promise<Response>;
export declare function CJMS_POST_SCORE(teamScore: TeamScoreContainer): Promise<Response>;
