import mongoose from "mongoose";
import { TeamScoreSchema } from "./team_score";

export const TeamSchema = new mongoose.Schema({
  team_numer: {type: String, required: true },
  team_name: {type: String},
  affiliation: {type: String},

  scores: [
    TeamScoreSchema
  ],

  ranking: {type: Number}
});

export const TeamModel = mongoose.model('Team', TeamSchema);