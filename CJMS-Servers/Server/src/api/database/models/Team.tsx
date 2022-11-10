import mongoose from "mongoose";
import { ITeam } from "@cjms_shared/services";
import { TeamScoreSchema } from "./TeamScore";

export const TeamSchema = new mongoose.Schema<ITeam>({
  team_number: {type: String, required: true },
  team_name: {type: String},
  team_id: {type: String, default: ''},
  affiliation: {type: String},

  scores: [
    TeamScoreSchema
  ],

  ranking: {type: Number}
}, {timestamps: true});

export const TeamModel = mongoose.model<ITeam>('Team', TeamSchema);