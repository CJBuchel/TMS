import mongoose from "mongoose";

// Table Schema (just a name)
export const TableSchema = new mongoose.Schema({
  table: {type: String},
});

export const TableModel = mongoose.model('Table', TableSchema);