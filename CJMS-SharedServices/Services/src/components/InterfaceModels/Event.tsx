export interface IOnlineLink {
  tournament_id: string;
  tournament_token: string;
  online_linked: boolean;
}

export interface IEvent {
  event_name: string;
  event_csv: JSON;

  event_tables: string[];
  event_rounds: number;

  season: number;

  match_locked: boolean;

  online_link: IOnlineLink;
}

export function initIOnlineLink(instance?:IOnlineLink) {
  const defaults:IOnlineLink = {
    tournament_id: '',
    tournament_token: '',
    online_linked: false
  }

  return {
    ...defaults,
    ...instance
  }
}

export function initIEvent(instance?:IEvent) {
  const defaults:IEvent = {
    event_name: '',
    event_csv: JSON,
    event_tables: [],
    event_rounds: 3,

    season: 20222023,

    match_locked: false,

    online_link: initIOnlineLink()
  }

  return {
    ...defaults,
    ...instance
  }
}