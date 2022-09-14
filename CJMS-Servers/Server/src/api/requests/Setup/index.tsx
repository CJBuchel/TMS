import { RequestServer } from "../RequestServer";
import { comm_service, request_namespaces } from "@cjms_shared/services";
import mongoose from "mongoose";
import { setupUsers } from "../../database/models/User";
import { EventModel } from "../../database/models/Event";
import { setupTeams } from "./setupTeams";
import { setupMatches } from "./setupMatches";
import { setupJudgingSessions } from "./setupJudgingSessions";

export class Setup {

  constructor(requestServer:RequestServer) {
    console.log("Setup Requests Constructed");

    requestServer.get().post(request_namespaces.request_post_setup, async (req, res) => {
      const eventName = req.body.eventName;
      const csv = req.body.csv;

      const team_block:any[] = [];
      const match_block:any[] = [];
      const judging_block:any[] = [];

      const block_format = "Block Format";
      
      var blockNumber = -1;
      for (const line of csv) {
        if (line[0] == block_format && line[1] == 1) {
          blockNumber = 0;
        } else if (line[0] == block_format && line[1] == 2) {
          blockNumber = 1;
        } else if (line[0] == block_format && line[1] == 3) {
          blockNumber = 2
        }

        switch (blockNumber) {
          case 0:
            team_block.push(line);
            break;
          case 1:
            match_block.push(line);
            break;
          case 2:
            judging_block.push(line);
            break;
        }
      }

      const table_names = match_block[5].slice(1,-1);

      await setupTeams(team_block);
      await setupMatches(match_block);
      await setupJudgingSessions(judging_block);
      
      // Setup event model
      await new EventModel({event_name: eventName, event_csv: csv, event_tables: table_names}).save();
      res.send({message: "Successfully Imported Setup"});

      comm_service.senders.sendEventUpdateEvent('setup');
    });

    requestServer.get().use(request_namespaces.request_post_purge, (req, res) => {
      mongoose.connection.db.dropDatabase();
      setupUsers();
      res.send({message: "Successfully Purged Database"});
      comm_service.senders.sendEventUpdateEvent('purge');
    });
  }
}