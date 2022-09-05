"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMatchUpdate = exports.onTeamUpdate = exports.onClockEndGameEvent = exports.onClockReloadEvent = exports.onClockStartEvent = exports.onClockPrestartEvent = exports.onClockTimeEvent = exports.onClockStopEvent = exports.onClockEndEvent = exports.onClockArmEvent = void 0;
const subscribe_1 = require("./binding/subscribe");
// Clock Events
exports.onClockArmEvent = subscribe_1.onEvent.bind(null, 'clock', 'arm');
exports.onClockEndEvent = subscribe_1.onEvent.bind(null, 'clock', 'end');
exports.onClockStopEvent = subscribe_1.onEvent.bind(null, 'clock', 'stop');
exports.onClockTimeEvent = subscribe_1.onEvent.bind(null, 'clock', 'time');
exports.onClockPrestartEvent = subscribe_1.onEvent.bind(null, 'clock', 'prestart');
exports.onClockStartEvent = subscribe_1.onEvent.bind(null, 'clock', 'start');
exports.onClockReloadEvent = subscribe_1.onEvent.bind(null, 'clock', 'reload');
exports.onClockEndGameEvent = subscribe_1.onEvent.bind(null, 'clock', 'endgame');
// Team/Score Events
exports.onTeamUpdate = subscribe_1.onEvent.bind(null, 'team', 'update');
// Match Updates
exports.onMatchUpdate = subscribe_1.onEvent.bind(null, 'match', 'update');
