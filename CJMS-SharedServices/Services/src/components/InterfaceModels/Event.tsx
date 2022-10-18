export interface IEvent {
  event_name: string;
  tournament_id: string;
  event_csv: JSON;

  event_tables: string[];
  event_rounds: number;

  season: number;

  match_locked: boolean;
}

export function initIEvent(instance?:IEvent) {
  const defaults:IEvent = {
    event_name: '',
    tournament_id: '',
    event_csv: JSON,
    event_tables: [],
    event_rounds: 3,

    season: 20222023,

    match_locked: false
  }

  return {
    ...defaults,
    ...instance
  }
}