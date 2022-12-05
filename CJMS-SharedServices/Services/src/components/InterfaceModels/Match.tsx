import { ITimestamps } from "./Timestamps";

interface OnTable extends ITimestamps {
  table: string;
  team_number: string;
  score_submitted: boolean;
}

export interface IMatch extends ITimestamps {
  match_number: string;

  start_time: string;
  end_time: string;

  on_table1: OnTable;
  on_table2: OnTable;

  complete: boolean;
  deferred: boolean;
  custom_match: boolean;
}

export function initIMatch(instance?:IMatch) {
  const defaults:IMatch = {
    match_number: '',

    start_time: '',
    end_time: '',

    on_table1: {table: '', team_number: '', score_submitted: false, createdAt: null, updatedAt: null},
    on_table2: {table: '', team_number: '', score_submitted: false, createdAt: null, updatedAt: null},

    complete: false,
    deferred: false,
    custom_match: false
  }

  return {
    ...defaults,
    ...instance
  }
}