import mongoose from "mongoose"

// Scored Match Schema, has the main score, gp, notes. plus the scoresheet values
export const TeamScoreSchema = new mongoose.Schema({
  score: {type: Number},
  gp: {type: Number},
  scoresheet_values: [{type: Number}],
  notes: {type: String}
});