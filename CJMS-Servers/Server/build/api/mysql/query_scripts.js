"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_sql_update_team = exports.sql_update_team_row = exports.sql_new_team = exports.sql_get_team_by_name = exports.sql_get_teams = exports.get_sql_update_match = exports.sql_new_match = exports.sql_get_matches = exports.get_sql_update_judging_schedule = exports.sql_new_judging_schedule = exports.sql_get_judging_schedule = exports.sql_get_all_judging_schedule = exports.get_sql_update_match_schedule = exports.sql_new_match_schedule = exports.sql_get_match_schedule = exports.sql_get_all_match_schedule = exports.get_sql_update_user = exports.sql_update_user = exports.sql_get_users = exports.sql_get_user = exports.get_sql_purge_script = exports.sql_purge_table = exports.get_sql_update = exports.sql_table_names_arr = exports.sql_table_names_all_arr = void 0;
// Tables
exports.sql_table_names_all_arr = [
    'users',
    'teams',
    'match_schedule',
    'judging_schedule',
    'matches'
];
exports.sql_table_names_arr = [
    'teams',
    'match_schedule',
    'judging_schedule',
    'matches'
];
function get_sql_update(table, set, set_value, where, where_value) {
    return (`UPDATE ${table} ${set} = ${set_value} WHERE ${where} = ${where_value};`);
}
exports.get_sql_update = get_sql_update;
// 
// Purge Scripts
// 
exports.sql_purge_table = "TRUNCATE TABLE";
function get_sql_purge_script(table_names_arr) {
    var sql_purge_script;
    for (var table_name of table_names_arr) {
        sql_purge_script.push(`${exports.sql_purge_table} ${table_name};`);
    }
    return sql_purge_script;
}
exports.get_sql_purge_script = get_sql_purge_script;
// 
// User Scripts
// 
exports.sql_get_user = "SELECT * FROM users WHERE name = ? AND password = ?;";
exports.sql_get_users = "SELECT * FROM users ORDER BY id ASC;";
exports.sql_update_user = "UPDATE users SET password = ? WHERE name = ?;";
function get_sql_update_user(set, set_value, where, where_value) {
    return get_sql_update("users", set, set_value, where, where_value);
}
exports.get_sql_update_user = get_sql_update_user;
// 
// Match Schedule Scripts
// 
exports.sql_get_all_match_schedule = "SELECT * FROM match_schedule ORDER BY id ASC;";
exports.sql_get_match_schedule = "SELECT * FROM match_schedule WHERE match_number = ? AND team_number = ?;";
exports.sql_new_match_schedule = "INSERT INTO match_schedule (match_number, start_time, end_time, team_number, on_table) VALUES (?,?,?,?,?);";
function get_sql_update_match_schedule(set, set_value, where, where_value) {
    return get_sql_update("matches", set, set_value, where, where_value);
}
exports.get_sql_update_match_schedule = get_sql_update_match_schedule;
// 
// Judging Schedule Scripts
// 
exports.sql_get_all_judging_schedule = "SELECT * FROM judging_schedule ORDER BY id ASC;";
exports.sql_get_judging_schedule = "SELECT * FROM match_schedule WHERE room_name = ? AND team_number = ?;";
exports.sql_new_judging_schedule = "INSERT INTO judging_schedule (start_time, end_time, team_number, room_name) VALUES (?,?,?,?);";
function get_sql_update_judging_schedule(set, set_value, where, where_value) {
    return get_sql_update("judging_schedule", set, set_value, where, where_value);
}
exports.get_sql_update_judging_schedule = get_sql_update_judging_schedule;
// 
// Match Scripts
// 
exports.sql_get_matches = "SELECT * FROM matches ORDER BY next_match_number ASC;";
exports.sql_new_match = "INSERT INTO matches (next_match_number, next_start_time, next_end_time, on_table1, on_table2, next_team1_number, next_team2_number) VALUES (?,?,?,?,?,?,?);";
function get_sql_update_match(set, set_value, where, where_value) {
    return get_sql_update("matches", set, set_value, where, where_value);
}
exports.get_sql_update_match = get_sql_update_match;
// 
// Team Scripts
// 
exports.sql_get_teams = "SELECT * FROM teams ORDER BY ranking ASC;";
exports.sql_get_team_by_name = "SELECT * FROM teams WHERE team_name = ?;";
exports.sql_new_team = "INSERT INTO teams (team_number, team_name, affiliation) VALUES (?, ?, ?);";
exports.sql_update_team_row = "UPDATE teams SET team_number = ?, team_name = ?, affiliation = ?, match_score_1 = ?, match_score_2 = ?, match_score_3 = ?, match_gp_1 = ?, match_gp_2 = ?, match_gp_3 = ?, team_notes_1 = ?, team_notes_2 = ?, team_notes_3 = ?, ranking = ? WHERE team_number = ?";
function get_sql_update_team(set, set_value, where, where_value) {
    return get_sql_update("teams", set, set_value, where, where_value);
}
exports.get_sql_update_team = get_sql_update_team;
