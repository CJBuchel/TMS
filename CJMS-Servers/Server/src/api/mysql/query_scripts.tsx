
// Tables
export const sql_table_names_all_arr = [
  'users', 
  'teams',
  'match_schedule',
  'judging_schedule',
  'matches'
];

export const sql_table_names_arr = [
  'teams',
  'match_schedule',
  'judging_schedule',
  'matches'
]

export function get_sql_update(table:string, set:string, set_value:string, where:string, where_value:string) {
  return (
    `UPDATE ${table} ${set} = ${set_value} WHERE ${where} = ${where_value};`
  );
}

// 
// Purge Scripts
// 
export const sql_purge_table = "TRUNCATE TABLE";
export function get_sql_purge_script(table_names_arr:any) {
  var sql_purge_script:any;
  for (var table_name of table_names_arr) {
    sql_purge_script.push(`${sql_purge_table} ${table_name};`);
  }

  return sql_purge_script;
}

// 
// User Scripts
// 
export const sql_get_user = "SELECT * FROM users WHERE name = ? AND password = ?;";
export const sql_get_users = "SELECT * FROM users ORDER BY id ASC;";
export const sql_update_user = "UPDATE users SET password = ? WHERE name = ?;";
export function get_sql_update_user(set:string, set_value:string, where:string, where_value:string) {
  return get_sql_update("users", set, set_value, where, where_value);
}

// 
// Match Schedule Scripts
// 
export const sql_get_all_match_schedule = "SELECT * FROM match_schedule ORDER BY id ASC;";
export const sql_get_match_schedule = "SELECT * FROM match_schedule WHERE match_number = ? AND team_number = ?;";
export const sql_new_match_schedule = "INSERT INTO match_schedule (match_number, start_time, end_time, team_number, on_table) VALUES (?,?,?,?,?);";
export function get_sql_update_match_schedule(set:string, set_value:string, where:string, where_value:string) {
  return get_sql_update("matches", set, set_value, where, where_value);
}

// 
// Judging Schedule Scripts
// 
export const sql_get_all_judging_schedule = "SELECT * FROM judging_schedule ORDER BY id ASC;";
export const sql_get_judging_schedule = "SELECT * FROM match_schedule WHERE room_name = ? AND team_number = ?;";
export const sql_new_judging_schedule = "INSERT INTO judging_schedule (start_time, end_time, team_number, room_name) VALUES (?,?,?,?);";
export function get_sql_update_judging_schedule(set:string, set_value:string, where:string, where_value:string) {
  return get_sql_update("judging_schedule", set, set_value, where, where_value);
}

// 
// Match Scripts
// 
export const sql_get_matches = "SELECT * FROM matches ORDER BY next_match_number ASC;";
export const sql_new_match = "INSERT INTO matches (next_match_number, next_start_time, next_end_time, on_table1, on_table2, next_team1_number, next_team2_number) VALUES (?,?,?,?,?,?,?);";
export function get_sql_update_match(set:string, set_value:string, where:string, where_value:string) {
  return get_sql_update("matches", set, set_value, where, where_value);
}

// 
// Team Scripts
// 
export const sql_get_teams = "SELECT * FROM teams ORDER BY ranking ASC;";
export const sql_get_team_by_name = "SELECT * FROM teams WHERE team_name = ?;";
export const sql_new_team = "INSERT INTO teams (team_number, team_name, affiliation) VALUES (?, ?, ?);";
export const sql_update_team_row = "UPDATE teams SET team_number = ?, team_name = ?, affiliation = ?, match_score_1 = ?, match_score_2 = ?, match_score_3 = ?, match_gp_1 = ?, match_gp_2 = ?, match_gp_3 = ?, team_notes_1 = ?, team_notes_2 = ?, team_notes_3 = ?, ranking = ? WHERE team_number = ?";
export function get_sql_update_team(set:string, set_value:string, where:string, where_value:string) {
  return get_sql_update("teams", set, set_value, where, where_value);
}