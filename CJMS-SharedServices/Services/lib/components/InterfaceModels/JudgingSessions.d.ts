import { ITimestamps } from "./Timestamps";
export interface IJudgingSession extends ITimestamps {
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
    createdAt?: Date;
    updatedAt?: Date;
};
