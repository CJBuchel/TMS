import {ITeamScore} from "./TeamScore";

export interface ITeam {
  team_number: string;
  team_name: string;
  affiliation: string;

  scores: ITeamScore[];

  ranking: number;
}

export function initITeam(instance?:ITeam) {
  const defaults:ITeam = {
    team_number: '',
    team_name: '',
    affiliation: '',

    scores: [],

    ranking: 0
  }

  return {
    ...defaults,
    ...instance
  }
}