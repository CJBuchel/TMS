import 'package:tms/schema/tms_schema.dart';

class MatchError {
  final String message;
  final String? matchNumber;
  final String? teamNumber;

  const MatchError({
    required this.message,
    this.matchNumber,
    this.teamNumber,
  });
}

class MatchErrorChecks {
  static List<GameMatch> _matches = [];
  static List<Team> _teams = [];
  static Event? _event;

  static List<MatchError> onTableErrors() {
    List<MatchError> errors = [];
    List<String> tables = _event?.tables ?? [];
    for (var match in _matches) {
      // check on the tables
      for (var onTable in match.matchTables) {
        // check if table is blank
        if (onTable.table.isNotEmpty && !tables.contains(onTable.table)) {
          errors.add(MatchError(message: "Table ${onTable.table} does not exist in this event", matchNumber: match.matchNumber));
        }
      }
    }
    return errors;
  }

  static List<MatchError> _teamErrors() {
    List<MatchError> errors = [];

    int rounds = _event?.eventRounds ?? 0;
    for (var team in _teams) {
      int teamMatches = 0;
      for (var match in _matches) {
        for (var onTable in match.matchTables) {
          if (onTable.teamNumber == team.teamNumber) {
            teamMatches++;
          }
        }
      }

      if (teamMatches < rounds) {
        errors.add(MatchError(message: "Team has less matches than the number of rounds", teamNumber: team.teamNumber));
      } else if (teamMatches > rounds) {
        errors.add(MatchError(message: "Team has more matches than the number of rounds", teamNumber: team.teamNumber));
      }
    }

    return errors;
  }

  static List<MatchError> getErrors({
    required List<GameMatch> matches,
    required List<Team> teams,
    required Event? event,
  }) {
    _matches = matches;
    _teams = teams;
    _event = event;
    return [
      ...onTableErrors(),
      ..._teamErrors(),
    ];
  }
}
