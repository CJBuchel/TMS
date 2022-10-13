export interface TeamScoresheet {
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

export interface TeamScoreContainer {
  // TMS Specific data
  gp: number;
  referee: string;
  no_show: boolean;
  score: number;

  // Generalized Scoresheet
  valid_scoresheet: boolean;
  scoresheet: TeamScoresheet;
}