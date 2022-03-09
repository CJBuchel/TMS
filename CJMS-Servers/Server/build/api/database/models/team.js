"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamModel = exports.TeamSchema = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const team_score_1 = require("./team_score");
exports.TeamSchema = new mongoose_1.default.Schema({
    team_numer: { type: String, required: true },
    team_name: { type: String },
    affiliation: { type: String },
    scores: [
        team_score_1.TeamScoreSchema
    ],
    ranking: { type: Number }
});
exports.TeamModel = mongoose_1.default.model('Team', exports.TeamSchema);
