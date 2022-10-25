import {ITeamScore} from "./TeamScore";
import { ITimestamps } from "./Timestamps";

export interface ITeam extends ITimestamps {
  team_number: string;
  team_name: string;
  team_id: string;
  affiliation: string;

  scores: ITeamScore[];

  ranking: number;
}

export function initITeam(instance?:ITeam) {
  const defaults:ITeam = {
    team_number: '',
    team_name: '',
    team_id: '',
    affiliation: '',

    scores: [],

    ranking: 0
  }

  return {
    ...defaults,
    ...instance
  }
}