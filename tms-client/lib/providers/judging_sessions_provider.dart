import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/utils/sorter_util.dart';

class JudgingSessionsProvider extends EchoTreeProvider<String, JudgingSession> {
  JudgingSessionsProvider()
      : super(tree: ":judging:sessions", fromJsonString: (json) => JudgingSession.fromJsonString(json: json));

  List<JudgingSession> get judgingSessions => judgingSessionsByTime;

  List<JudgingSession> get judgingSessionsByNumber {
    List<JudgingSession> sessions = items.values.toList();
    return sortJudgingSessionsBySessionNumber(sessions);
  }

  List<JudgingSession> get judgingSessionsByTime {
    List<JudgingSession> sessions = items.values.toList();
    return sortJudgingSessionsByTime(sessions);
  }
}
