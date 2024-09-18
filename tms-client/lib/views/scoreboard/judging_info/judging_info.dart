import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/providers/judging_sessions_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/views/scoreboard/judging_info/judging_schedule.dart';

class JudgingInfo extends StatelessWidget {
  const JudgingInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector2<
        JudgingSessionsProvider,
        TmsLocalStorageProvider,
        ({
          List<JudgingSession> sessions,
          bool showJudgingInfo,
        })>(
      selector: (_, jdProvider, lsProvider) => (
        sessions: jdProvider.judgingSessionsByTime,
        showJudgingInfo: lsProvider.scoreboardShowJudgingInfo,
      ),
      builder: (context, data, _) {
        if (data.showJudgingInfo) {
          return JudgingSchedule(
            judgingSessions: data.sessions,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
