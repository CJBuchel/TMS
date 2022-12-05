import mongoose from "mongoose";
import { IMatch } from "@cjms_shared/services";

// Team on table Schema, (used internally only with Match Schema)
const OnTableSchema = new mongoose.Schema({
  table: {type: String},
  team_number: {type: String},
  score_submitted: {type: Boolean, default: false}
}, {timestamps: true});

// Match
export const MatchSchema = new mongoose.Schema<IMatch>({
  match_number: {type: String, required: true},

  // Time when match starts/ends
  start_time: {type: String},
  end_time: {type: String},

  // Table names/numbers e.g table1 pink, table2 red
  on_table1: OnTableSchema,
  on_table2: OnTableSchema,

  complete: {type: Boolean, default: false},
  deferred: {type: Boolean, default: false},
  custom_match: {type: Boolean, default: false}
}, {timestamps: true});

export const MatchModel = mongoose.model<IMatch>('Match', MatchSchema);