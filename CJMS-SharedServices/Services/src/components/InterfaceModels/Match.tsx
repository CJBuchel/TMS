
interface OnTable {
  table: string;
  team_number: string;
  score_submitted: boolean;
}

export interface IMatch {
  match_number: string;

  start_time: string;
  end_time: string;

  on_table1: OnTable;
  on_table2: OnTable;

  complete: boolean;
  rescheduled: boolean;
}

export function initIMatch(instance?:IMatch) {
  const defaults:IMatch = {
    match_number: '',

    start_time: '',
    end_time: '',

    on_table1: {table: '', team_number: '', score_submitted: false},
    on_table2: {table: '', team_number: '', score_submitted: false},

    complete: false,
    rescheduled: false
  }

  return {
    ...defaults,
    ...instance
  }
}