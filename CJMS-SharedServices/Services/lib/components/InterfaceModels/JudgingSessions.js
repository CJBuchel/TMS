"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initIJudgingSession = void 0;
function initIJudgingSession(instance) {
    const defaults = {
        session: '',
        start_time: '',
        end_time: '',
        room: '',
        team_number: ''
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIJudgingSession = initIJudgingSession;
