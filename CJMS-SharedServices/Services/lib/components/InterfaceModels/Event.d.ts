export interface IOnlineLink {
    tournament_id: string;
    tournament_token: string;
    online_linked: boolean;
}
export interface IEvent {
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
};
export declare function initIEvent(instance?: IEvent): {
    event_name: string;
    event_csv: JSON;
    event_tables: string[];
    event_rounds: number;
    season: number;
    match_locked: boolean;
    online_link: IOnlineLink;
};
