"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamScoreSchema = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
// Scored Match Schema, has the main score, gp, notes. plus the scoresheet values
exports.TeamScoreSchema = new mongoose_1.default.Schema({
    score: { type: Number },
    gp: { type: Number },
    scoresheet_values: [{ type: Number }],
    notes: { type: String }
});
