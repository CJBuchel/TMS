import { ITimestamps } from "./Timestamps";
export interface ITeamScoresheet extends ITimestamps {
    team_id: string;
    tournament_id: string;
    round: number;
    answers: {
        id: string;
        answer: string;
    }[];
    private_comment: string;
    public_comment: string;
}
export interface ITeamScore extends ITimestamps {
    gp: string;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    cloud_published: boolean;
    scoresheet: ITeamScoresheet;
}
export declare function initITeamScore(instance?: ITeamScore): {
    gp: string;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    cloud_published: boolean;
    scoresheet: ITeamScoresheet;
    createdAt?: Date;
    updatedAt?: Date;
};
