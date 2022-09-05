import mongoose from "mongoose"

// Scored Match Schema, has the main score, gp, notes. plus the scoresheet values
export const TeamScoreSchema = new mongoose.Schema({
  roundIndex: {type: Number, required: true},
  score: {type: Number},
  gp: {type: Number},
  scored_by: {type: String},
  scoresheet_values: [{type: Number}],
  notes: {type: String}
});