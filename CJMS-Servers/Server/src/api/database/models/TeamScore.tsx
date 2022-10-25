import mongoose from "mongoose"

import { ITeamScore } from "@cjms_shared/services";

const AnswerSchema = new mongoose.Schema({
  id: {type: String, required: true},
  answer: {type: String}
}, {timestamps: true});

// Scoresheet, used as a container for each round score for a team, and is published to FLL System
export const TeamScoresheetSchema = new mongoose.Schema({
  // header data
  team_id: {type: String, required: true},
  tournament_id: {type: String, required: true},
  round: {type: Number, required: true},

  // Score data
  answers: [AnswerSchema],
  private_comment: {type: String},
  public_comment: {type: String}
}, {timestamps: true});

// Scored Match Schema, has the main score, gp, notes. plus the scoresheet values
export const TeamScoreSchema = new mongoose.Schema<ITeamScore>({
  gp: {type: String},
  referee: {type: String},
  no_show: {type: Boolean},
  score: {type: Number},

  valid_scoresheet: {type: Boolean, required: true},
  scoresheet: TeamScoresheetSchema
}, {timestamps: true});