export interface ITeamScoresheet {
  // Header data
  team_id: string;
  tournament_id: string;
  round: number;

  // Answers
  answers: {
    id: string;
    answer: string;
  }[];
  private_comment: string;
  public_comment: string;
}

export interface ITeamScore {
  // TMS Specific data
  gp: number;
  referee: string;
  no_show: boolean;
  score: number;

  // Generalized Scoresheet
  valid_scoresheet: boolean;
  scoresheet: ITeamScoresheet;
}

export function initITeamScore(instance?:ITeamScore) {
  const defaults:ITeamScore = {
    gp: 0,
    referee: '',
    no_show: false,
    score: 0,

    valid_scoresheet: false,
    scoresheet: {
      team_id: '',
      tournament_id: '',
      round: 0,

      answers: [],
      private_comment: '',
      public_comment: ''
    }
  }

  return {
    ...defaults,
    ...instance
  }
}