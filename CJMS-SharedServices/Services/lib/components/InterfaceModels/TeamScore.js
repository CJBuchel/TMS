"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initITeamScore = void 0;
function initITeamScore(instance) {
    const defaults = {
        gp: '',
        referee: '',
        no_show: false,
        score: 0,
        valid_scoresheet: false,
        cloud_published: false,
        scoresheet: {
            // team_id: '',
            tournament_id: '',
            round: 0,
            answers: [],
            private_comment: '',
            public_comment: ''
        }
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initITeamScore = initITeamScore;
