export interface IJudgingSession {
    session: string;
    start_time: string;
    end_time: string;
    room: string;
    team_number: string;
}
export declare function initIJudgingSession(instance?: IJudgingSession): {
    session: string;
    start_time: string;
    end_time: string;
    room: string;
    team_number: string;
};
