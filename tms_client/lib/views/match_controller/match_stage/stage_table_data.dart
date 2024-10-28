import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class StageTableData {
  GameMatchTable table;
  bool submittedPrior;
  String matchNumber;
  Team team;

  StageTableData({
    required this.table,
    required this.submittedPrior,
    required this.matchNumber,
    required this.team,
  });
}
