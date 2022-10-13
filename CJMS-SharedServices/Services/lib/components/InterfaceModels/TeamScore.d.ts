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
export interface ITeamScore {
    gp: number;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    scoresheet: ITeamScoresheet;
}
export declare function initITeamScore(instance?: ITeamScore): {
    gp: number;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    scoresheet: ITeamScoresheet;
};
