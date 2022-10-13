import * as request_namespaces from "./components/Namespaces/namespaces";
import * as comm_service from "./components/CommService";
import { ITeamScore, initITeamScore } from "./components/InterfaceModels/TeamScore";
import { ITeam, initITeam } from "./components/InterfaceModels/Team";
import { IMatch, initIMatch} from "./components/InterfaceModels/Match";
import { IEvent, initIEvent } from "./components/InterfaceModels/Event";
import { IUser, initIUser } from "./components/InterfaceModels/User";
import { IJudgingSession, initIJudgingSession } from "./components/InterfaceModels/JudgingSessions";

export { 
  request_namespaces, 
  comm_service,

  // Interfaces
  ITeamScore, initITeamScore,
  ITeam, initITeam,
  IMatch, initIMatch,
  IEvent, initIEvent,
  IUser, initIUser,
  IJudgingSession, initIJudgingSession
};