import { ITeamScore } from "./TeamScore";
import { ITimestamps } from "./Timestamps";
export interface ITeam extends ITimestamps {
    team_number: string;
    team_name: string;
    team_id: string;
    affiliation: string;
    scores: ITeamScore[];
    ranking: number;
}
export declare function initITeam(instance?: ITeam): {
    team_number: string;
    team_name: string;
    team_id: string;
    affiliation: string;
    scores: ITeamScore[];
    ranking: number;
    createdAt?: Date;
    updatedAt?: Date;
};
