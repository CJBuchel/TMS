export interface IEvent {
    event_name: string;
    event_csv: JSON;
    event_tables: string[];
    event_rounds: number;
    season: number;
    match_locked: boolean;
}
export declare function initIEvent(instance?: IEvent): {
    event_name: string;
    event_csv: JSON;
    event_tables: string[];
    event_rounds: number;
    season: number;
    match_locked: boolean;
};
