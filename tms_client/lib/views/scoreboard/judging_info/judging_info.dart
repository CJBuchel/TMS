import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/views/scoreboard/judging_info/judging_schedule.dart';

class JudgingInfo extends StatelessWidget {
  const JudgingInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<JudgingSessionProvider, List<JudgingSession>>(
      selector: (_, jdProvider) => jdProvider.judgingSessionsByTime,
      builder: (context, data, _) {
        return JudgingSchedule(
          judgingSessions: data,
        );
      },
    );
  }
}
