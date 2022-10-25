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
}
export declare function initIMatch(instance?: IMatch): {
    match_number: string;
    start_time: string;
    end_time: string;
    on_table1: OnTable;
    on_table2: OnTable;
    complete: boolean;
    deferred: boolean;
    createdAt?: Date;
    updatedAt?: Date;
};
export {};
