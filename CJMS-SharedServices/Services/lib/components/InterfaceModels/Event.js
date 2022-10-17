"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initIEvent = void 0;
function initIEvent(instance) {
    const defaults = {
        event_name: '',
        event_csv: JSON,
        event_tables: [],
        event_rounds: 3,
        season: 20222023,
        match_locked: false
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIEvent = initIEvent;
