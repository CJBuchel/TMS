import 'package:tms/generated/infra/database_schemas/game_score_sheet.dart';

class TeamScoreSheet {
  String scoreSheetId;
  GameScoreSheet scoreSheet;

  TeamScoreSheet({
    required this.scoreSheetId,
    required this.scoreSheet,
  });
}
