import mongoose from "mongoose";
import { ITeam } from "@cjms_shared/services";
import { TeamScoreSchema } from "./TeamScore";

export const TeamSchema = new mongoose.Schema<ITeam>({
  team_number: {type: String, required: true },
  team_name: {type: String},
  affiliation: {type: String},

  scores: [
    TeamScoreSchema
  ],

  ranking: {type: Number}
});

export const TeamModel = mongoose.model<ITeam>('Team', TeamSchema);