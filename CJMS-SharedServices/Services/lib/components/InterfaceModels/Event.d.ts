import { ITimestamps } from "./Timestamps";
export interface IOnlineLink extends ITimestamps {
    tournament_id: string;
    tournament_token: string;
    online_linked: boolean;
}
export interface IEvent extends ITimestamps {
    event_name: string;
    event_csv: JSON;
    event_tables: string[];
    event_rounds: number;
    season: number;
    match_locked: boolean;
    online_link: IOnlineLink;
}
export declare function initIOnlineLink(instance?: IOnlineLink): {
    tournament_id: string;
    tournament_token: string;
    online_linked: boolean;
    createdAt?: Date;
    updatedAt?: Date;
};
export declare function initIEvent(instance?: IEvent): {
    event_name: string;
    event_csv: JSON;
    event_tables: string[];
    event_rounds: number;
    season: number;
    match_locked: boolean;
    online_link: IOnlineLink;
    createdAt?: Date;
    updatedAt?: Date;
};
