"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initITeam = void 0;
function initITeam(instance) {
    const defaults = {
        team_number: '',
        team_name: '',
        team_id: '',
        affiliation: '',
        scores: [],
        ranking: 0
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initITeam = initITeam;
