"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initIEvent = exports.initIOnlineLink = void 0;
function initIOnlineLink(instance) {
    const defaults = {
        tournament_id: '',
        tournament_token: '',
        online_linked: false,
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIOnlineLink = initIOnlineLink;
function initIEvent(instance) {
    const defaults = {
        event_name: '',
        event_csv: JSON,
        event_tables: [],
        event_rounds: 3,
        season: 20222023,
        match_locked: false,
        online_link: initIOnlineLink(),
    };
    return {
        ...defaults,
        ...instance
    };
}
exports.initIEvent = initIEvent;
