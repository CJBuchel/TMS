"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initIMatch = void 0;
function initIMatch(instance) {
    const defaults = {
        match_number: '',
        start_time: '',
        end_time: '',
        on_table1: { table: '', team_number: '', score_submitted: false, createdAt: null, updatedAt: null },
        on_table2: { table: '', team_number: '', score_submitted: false, createdAt: null, updatedAt: null },
        complete: false,
        deferred: false
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIMatch = initIMatch;
