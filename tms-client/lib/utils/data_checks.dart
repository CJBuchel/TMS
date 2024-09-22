import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';
import 'package:tms/generated/infra/database_schemas/game_table.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/models/base_check_message.dart';
import 'package:tms/utils/tms_time_utils.dart';

class DataChecks {
  static List<BaseCheckMessage> teamChecks({required Team team}) {
    List<BaseCheckMessage> checks = [];
    if (team.teamNumber.isEmpty) {
      checks.add(BaseCheckMessage(
        message: 'Team number is missing.',
        type: BaseCheckMessageType.error,
      ));
    }

    if (team.name.isEmpty) {
      checks.add(BaseCheckMessage(
        teamNumber: team.teamNumber,
        type: BaseCheckMessageType.warning,
        message: 'Team name is missing.',
      ));
    }
    return checks;
  }

  static List<BaseCheckMessage> teamListChecks({required List<Team> teams}) {
    List<BaseCheckMessage> checks = [];
    // check if any teams have duplicate numbers
    List<String> teamNames = [];
    for (Team team in teams) {
      if (teamNames.contains(team.teamNumber)) {
        checks.add(BaseCheckMessage(
          teamNumber: team.teamNumber,
          type: BaseCheckMessageType.warning,
          message: 'Duplicate team name.',
        ));
      } else {
        teamNames.add(team.teamNumber);
      }
    }
    return checks;
  }

  static List<BaseCheckMessage> teamGameScoreChecks({required Team team, required List<GameScoreSheet> scores}) {
    List<BaseCheckMessage> checks = [];
    // check conflicting rounds
    List<int> roundNumbers = [];
    for (GameScoreSheet score in scores) {
      // check conflicting rounds
      if (roundNumbers.contains(score.round)) {
        checks.add(BaseCheckMessage(
          teamNumber: team.teamNumber,
          type: BaseCheckMessageType.error,
          message: 'Team has conflicting scores for round ${score.round}.',
        ));
      } else {
        roundNumbers.add(score.round);
      }

      // check if there is a round 0
      if (score.round == 0) {
        checks.add(BaseCheckMessage(
          teamNumber: team.teamNumber,
          type: BaseCheckMessageType.warning,
          message: 'Team has a score for round 0.',
        ));
      }
    }
    return checks;
  }

  static List<BaseCheckMessage> gameMatchChecks({
    required GameMatch match,
    required List<GameTable> tables,
    required List<JudgingSession> sessions,
    required List<Team> teams,
  }) {
    List<BaseCheckMessage> checks = [];

    // check if any matches have empty tables
    if (match.gameMatchTables.isEmpty) {
      checks.add(BaseCheckMessage(
        type: BaseCheckMessageType.warning,
        message: 'No tables or teams found in match.',
      ));
    }

    // on table checks
    for (var onTable in match.gameMatchTables) {
      // is match complete but not submitted?
      if (match.completed) {
        if (!onTable.scoreSubmitted) {
          checks.add(BaseCheckMessage(
            type: BaseCheckMessageType.warning,
            matchNumber: match.matchNumber,
            teamNumber: onTable.teamNumber,
            message: '${onTable.table}, match is complete but score not submitted.',
          ));
        }
      }
      // if match is not complete, but score submitted
      if (!match.completed) {
        if (onTable.scoreSubmitted) {
          checks.add(BaseCheckMessage(
            type: BaseCheckMessageType.warning,
            matchNumber: match.matchNumber,
            teamNumber: onTable.teamNumber,
            message: '${onTable.table}, score submitted but match is not complete.',
          ));
        }
      }

      // check if table is blank
      if (onTable.teamNumber.isEmpty) {
        checks.add(BaseCheckMessage(
          type: BaseCheckMessageType.warning,
          matchNumber: match.matchNumber,
          message: 'Blank table in match.',
        ));
      }

      // if team is empty
      if (onTable.teamNumber.isEmpty) {
        checks.add(BaseCheckMessage(
          type: BaseCheckMessageType.warning,
          matchNumber: match.matchNumber,
          message: 'No team on table ${onTable.table}.',
        ));
      }

      // check if table exists in this event
      if (!tables.any((element) => element.tableName == onTable.table)) {
        checks.add(BaseCheckMessage(
          type: BaseCheckMessageType.error,
          matchNumber: match.matchNumber,
          teamNumber: onTable.teamNumber,
          message: 'Table ${onTable.table} does not exist in this event.',
        ));
      }

      // check if any sessions are within 10 minutes of match
      for (var session in sessions) {
        DateTime matchStartTime = tmsDateTimeToDateTime(match.startTime);
        DateTime sessionStartTime = tmsDateTimeToDateTime(session.startTime);
        for (var pod in session.judgingSessionPods) {
          if (pod.teamNumber == onTable.teamNumber) {
            if (sessionStartTime.difference(matchStartTime).inMinutes.abs() < 10) {
              checks.add(BaseCheckMessage(
                type: BaseCheckMessageType.warning,
                matchNumber: match.matchNumber,
                teamNumber: onTable.teamNumber,
                sessionNumber: session.sessionNumber,
                message: 'Team has judging session within 10 minutes of match.',
              ));
            }
          }
        }
      }

      // check if team exists in this event
      if (!teams.any((element) => element.teamNumber == onTable.teamNumber)) {
        checks.add(BaseCheckMessage(
          type: BaseCheckMessageType.error,
          matchNumber: match.matchNumber,
          teamNumber: onTable.teamNumber,
          message: 'Team ${onTable.teamNumber} does not exist in this event.',
        ));
      }
    }

    return checks;
  }

  static List<BaseCheckMessage> gameMatchListChecks({
    required List<GameMatch> matches,
    required List<Team> teams,
  }) {
    List<BaseCheckMessage> checks = [];
    // check if any matches have duplicate numbers
    List<String> matchNumbers = [];
    for (GameMatch match in matches) {
      if (matchNumbers.contains(match.matchNumber)) {
        checks.add(BaseCheckMessage(
          matchNumber: match.matchNumber,
          type: BaseCheckMessageType.warning,
          message: 'Duplicate match number.',
        ));
      } else {
        matchNumbers.add(match.matchNumber);
      }
    }

    // count the number of rounds by checking each team, and checking how many matches they are in
    int maxRounds = 0;
    for (var team in teams) {
      int teamMatches = 0;
      for (var match in matches) {
        for (var table in match.gameMatchTables) {
          if (table.teamNumber == team.teamNumber) {
            teamMatches++;
          }
        }
      }
      if (teamMatches > maxRounds) {
        maxRounds = teamMatches;
      }
    }

    // check if all teams have the same number of rounds
    for (var team in teams) {
      int teamMatches = 0;
      for (var match in matches) {
        for (var table in match.gameMatchTables) {
          if (table.teamNumber == team.teamNumber) {
            teamMatches++;
          }
        }
      }
      if (teamMatches < maxRounds) {
        checks.add(BaseCheckMessage(
          teamNumber: team.teamNumber,
          type: BaseCheckMessageType.error,
          message: 'Team has fewer matches than the maximum number of rounds.',
        ));
      }
    }
    return checks;
  }
}
