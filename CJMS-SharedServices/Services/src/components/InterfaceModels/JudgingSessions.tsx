export interface IJudgingSession {
  session: string;

  start_time: string;
  end_time: string;

  room: string;

  team_number: string;
}

export function initIJudgingSession(instance?:IJudgingSession) {
  const defaults:IJudgingSession = {
    session: '',

    start_time: '',
    end_time: '',

    room: '',
    team_number: ''
  }

  return {
    ...defaults,
    ...instance
  }
}