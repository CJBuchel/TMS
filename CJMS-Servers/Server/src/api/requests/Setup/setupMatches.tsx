import { comm_service } from "@cjms_shared/services";
import { MatchModel } from "../../database/models/Match";

export async function setupMatches(match_block:any[]) {
  const table_names:any[] = match_block[5].slice(1,-1); // only care about the names
  const matches:any[] = match_block.slice(6);
  for (const match of matches) {
    const teams_on_tables:any[] = match.slice(3);
    const teams_on_table_index:number[] = [];

    for (let i = 0; i < teams_on_tables.length; i++) {
      if (teams_on_tables[i] != undefined && teams_on_tables[i] != '') {
        teams_on_table_index.push(i);
      }
    }

    await new MatchModel({
      match_number: match[0],
      start_time: match[1],
      end_time: match[2],

      on_table1: {
        table: table_names[teams_on_table_index[0]],
        team_number: teams_on_tables[teams_on_table_index[0]],
      },

      on_table2: {
        table: table_names[teams_on_table_index[1]],
        team_number: teams_on_tables[teams_on_table_index[1]],
      }
    }).save();
  }

  comm_service.senders.sendMatchUpdateEvent('setup');

  // Temp
  setTimeout(() => {
    comm_service.senders.sendMatchLoadedEvent("16");
  }, 5000);
}