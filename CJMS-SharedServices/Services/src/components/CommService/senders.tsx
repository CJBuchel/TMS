import { sendEvent } from "./binding/publish";

// Clock Events
export function sendClockArmEvent(e:any) { sendEvent('clock', 'arm', e) }
export function sendClockEndEvent(e:any) { sendEvent('clock', 'end', e) }
export function sendClockStopEvent(e:any) { sendEvent('clock', 'stop', e) }
export function sendClockTimeEvent(e:any) { sendEvent('clock', 'time', e) }
export function sendClockPrestartEvent(e:any) { sendEvent('clock', 'prestart', e) }
export function sendClockStartEvent(e:any) { sendEvent('clock', 'start', e) }
export function sendClockReloadEvent(e:any) { sendEvent('clock', 'reload', e) }
export function sendClockEndGameEvent(e:any) { sendEvent('clock', 'endgame', e) }

// Team/Score Events
export function sendTeamUpdateEvent(e:any) { sendEvent('team', 'update', e) }

// Match Update events
export function sendMatchUpdateEvent(e:any) { sendEvent('match', 'update', e) }

// Event updates
export function sendEventUpdateEvent(e:any) { sendEvent('event', 'update', e) }