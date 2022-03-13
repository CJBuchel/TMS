import { sendEvent } from "./binding/publish";

export function sendClockEndEvent(e) { sendEvent('clock', 'end', e) }
export function sendClockStopEvent(e) { sendEvent('clock', 'stop', e) }
export function sendClockTimeEvent(e) { sendEvent('clock', 'time', e) }
export function sendClockPrestartEvent(e) { sendEvent('clock', 'prestart', e) }
export function sendClockStartEvent(e) { sendEvent('clock', 'start', e) }
export function sendClockReloadEvent(e) { sendEvent('clock', 'reload', e) }
export function sendClockEndGameEvent(e) { sendEvent('clock', 'endgame', e) }