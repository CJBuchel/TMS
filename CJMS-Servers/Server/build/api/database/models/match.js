"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MatchModel = exports.MatchSchema = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const table_1 = require("./table");
// Team on table Schema, (used internally only with Match Schema)
const OnTableSchema = new mongoose_1.default.Schema({
    table: table_1.TableSchema,
    team_number: { type: String },
    score_submitted: { type: Boolean, default: false }
});
// Match
exports.MatchSchema = new mongoose_1.default.Schema({
    match_number: { type: Number, required: true },
    // Time when match starts/ends
    start_time: { type: String },
    end_time: { type: String },
    // Table names/numbers e.g table1 pink, table2 red
    on_table1: OnTableSchema,
    on_table2: OnTableSchema,
    complete: { type: Boolean, default: false },
    rescheduled: { type: Boolean, default: false }
});
exports.MatchModel = mongoose_1.default.model('Match', exports.MatchSchema);
