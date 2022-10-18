export interface ITeamScoresheet {
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
export declare type ITeamScoreGet = {
    compete_id: string;
    user_id: string;
    round: number;
    answers: {
        id: string;
        answer: string;
    }[];
    public_comment: string;
    private_comment: string;
    timestamp: Date;
};
export interface ITeamScore {
    gp: string;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    scoresheet: ITeamScoresheet;
}
export declare function initITeamScore(instance?: ITeamScore): {
    gp: string;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    scoresheet: ITeamScoresheet;
};
