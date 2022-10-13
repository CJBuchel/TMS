import { ITeamScore } from "./TeamScore";
export interface ITeam {
    team_number: string;
    team_name: string;
    affiliation: string;
    scores: ITeamScore[];
    ranking: number;
}
export declare function initITeam(instance?: ITeam): {
    team_number: string;
    team_name: string;
    affiliation: string;
    scores: ITeamScore[];
    ranking: number;
};
