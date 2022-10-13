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
export declare function initIMatch(instance?: IMatch): {
    match_number: string;
    start_time: string;
    end_time: string;
    on_table1: OnTable;
    on_table2: OnTable;
    complete: boolean;
    rescheduled: boolean;
};
export {};
