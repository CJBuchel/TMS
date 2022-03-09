import mongoose from "mongoose";
import { TableSchema } from "./table";

// Team on table Schema, (used internally only with Match Schema)
const OnTableSchema = new mongoose.Schema({
  table: TableSchema,
  team_number: {type: String},
  score_submitted: {type: Boolean, default: false}
});

// Match
export const MatchSchema = new mongoose.Schema({
  match_number: {type: Number, required: true},

  // Time when match starts/ends
  start_time: {type: String},
  end_time: {type: String},

  // Table names/numbers e.g table1 pink, table2 red
  on_table1: OnTableSchema,
  on_table2: OnTableSchema,

  complete: {type: Boolean, default: false},
  rescheduled: {type: Boolean, default: false}
});

export const MatchModel = mongoose.model('Match', MatchSchema);