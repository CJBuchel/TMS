import 'package:tms/schema/tms_schema.dart';

class TeamError {
  final String message;
  final String? teamNumber;

  const TeamError({
    required this.message,
    this.teamNumber,
  });
}

class SingleTeamErrorChecks {
  static Team? _team;

  static List<TeamError> _gameScoringErrors() {
    List<TeamError> errors = [];

    Map<int, List<TeamGameScore>> roundMap = {};

    for (TeamGameScore gameScore in _team?.gameScores ?? []) {
      if (roundMap.containsKey(gameScore.scoresheet.round)) {
        roundMap[gameScore.scoresheet.round]?.add(gameScore);
      } else {
        roundMap[gameScore.scoresheet.round] = [];
        roundMap[gameScore.scoresheet.round]?.add(gameScore);
      }
    }

    for (var round in roundMap.keys) {
      if ((roundMap[round]?.length ?? 0) > 1) {
        errors.add(TeamError(message: "Team has conflicting scores for round $round", teamNumber: _team?.teamNumber));
      }
    }

    return errors;
  }

  static List<TeamError> _judgingErrors() {
    List<TeamError> errors = [];
    return errors;
  }

  static List<TeamError> _genericTeamErrors() {
    List<TeamError> errors = [];

    if (_team?.teamNumber.isEmpty ?? true) {
      errors.add(TeamError(message: "Team number is blank", teamNumber: _team?.teamNumber));
    }

    if (_team?.teamName.isEmpty ?? true) {
      errors.add(TeamError(message: "Team name is blank", teamNumber: _team?.teamNumber));
    }

    return errors;
  }

  static List<TeamError> getErrors({
    required Team team,
  }) {
    _team = team;

    return [
      ..._gameScoringErrors(),
      ..._judgingErrors(),
      ..._genericTeamErrors(),
    ];
  }
}

class TeamErrorChecks {
  static List<TeamError> getErrors({
    required List<Team> teams,
  }) {
    List<TeamError> warnings = [];

    for (var team in teams) {
      warnings.addAll(SingleTeamErrorChecks.getErrors(team: team));
    }

    return warnings;
  }
}
