import { JudgingSessionModel } from "../../database/models/JudgingSession";


export async function setupJudgingSessions(judging_block:any[]) {
  const room_names:any[] = judging_block[5].slice(1, -1);
  const sessions:any[] = judging_block.slice(6);

  for (const session of sessions) {
    const teams_numbers:any[] = session.slice(3, -1);
    for (var i = 0; i < teams_numbers.length; i++) {
      new JudgingSessionModel({
        session: session[0], 
        start_time: session[1],
        end_time: session[2],
        room: room_names[i],
        team_number: teams_numbers[i], 
      }).save();
    }
  }
}