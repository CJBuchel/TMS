export interface TeamScoresheet {
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
export interface TeamScoreContainer {
    gp: number;
    referee: string;
    no_show: boolean;
    score: number;
    valid_scoresheet: boolean;
    scoresheet: TeamScoresheet;
}
