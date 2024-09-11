import 'package:tms/schema/tms_schema.dart';

class TeamWarning {
  final String message;
  final String? teamNumber;

  const TeamWarning({
    required this.message,
    this.teamNumber,
  });
}

class SingleTeamWarningChecks {
  static Team? _team;
  static Event? _event;

  static List<TeamWarning> _gameScoringWarnings() {
    List<TeamWarning> warnings = [];

    if ((_team?.gameScores.length ?? 0) > (_event?.eventRounds ?? 0)) {
      warnings.add(TeamWarning(message: "Team has more game scores than match rounds", teamNumber: _team?.teamNumber));
    }

    return warnings;
  }

  static List<TeamWarning> _judgingWarnings() {
    List<TeamWarning> warnings = [];

    if ((_team?.coreValuesScores.length ?? 0) > 1) {
      warnings.add(TeamWarning(message: "Team has more than one core values score", teamNumber: _team?.teamNumber));
    }
    if ((_team?.robotDesignScores.length ?? 0) > 1) {
      warnings.add(TeamWarning(message: "Team has more than one robot design score", teamNumber: _team?.teamNumber));
    }
    if ((_team?.innovationProjectScores.length ?? 0) > 1) {
      warnings.add(TeamWarning(message: "Team has more than one innovation project score", teamNumber: _team?.teamNumber));
    }

    return warnings;
  }

  static List<TeamWarning> _genericTeamWarnings() {
    List<TeamWarning> warnings = [];

    if (_team?.teamName.isEmpty ?? true) {
      warnings.add(TeamWarning(message: "Team name is blank", teamNumber: _team?.teamNumber));
    }

    return warnings;
  }

  static List<TeamWarning> getWarnings({
    required Team team,
    required Event? event,
  }) {
    _team = team;
    _event = event;
    return [
      ..._gameScoringWarnings(),
      ..._judgingWarnings(),
      ..._genericTeamWarnings(),
    ];
  }
}

class TeamWarningChecks {
  static List<TeamWarning> getWarnings({
    required List<Team> teams,
    required Event? event,
  }) {
    List<TeamWarning> warnings = [];

    for (var team in teams) {
      warnings.addAll(SingleTeamWarningChecks.getWarnings(team: team, event: event));
    }

    return warnings;
  }
}
