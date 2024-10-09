import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/judging_sessions/edit_session/edit_session_widget.dart';
import 'package:tms/views/judging_sessions/judging_info_banner.dart';
import 'package:tms/views/judging_sessions/on_add_session.dart';
import 'package:tms/views/judging_sessions/on_delete_session.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class JudgingSessions extends StatelessWidget {
  bool _hasPodSubmitted(JudgingSessionPod pod) {
    return pod.coreValuesSubmitted && pod.innovationSubmitted && pod.robotDesignSubmitted;
  }

  Widget _judgingSessionPods(
    BuildContext context,
    List<JudgingSessionPod> pods, {
    Color? backgroundColor,
    Color? submittedColor,
    bool isSessionComplete = false,
  }) {
    return Wrap(
      children: pods.map((p) {
        Color? c = _hasPodSubmitted(p)
            ? submittedColor
            : isSessionComplete
                ? Colors.red
                : backgroundColor;
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 100),
          child: SizedBox(
            width: 200,
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
                color: c,
              ),
              child: Column(
                children: [
                  Text(
                    p.podName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.teamNumber,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // selected pod variables
  final TextEditingController _sessionNumberController = TextEditingController();
  final ValueNotifier<TmsDateTime> _selectedStartTime = ValueNotifier(TmsDateTime());
  final ValueNotifier<TmsDateTime> _selectedEndTime = ValueNotifier(TmsDateTime());
  final ValueNotifier<bool> _selectedCompleted = ValueNotifier(false);

  List<EditTableRow> _rows(BuildContext context, List<JudgingSession> sessions) {
    return sessions.asMap().entries.map((entry) {
      int i = entry.key;
      JudgingSession s = entry.value;
      Color c = i.isEven ? Theme.of(context).cardColor : lighten(Theme.of(context).cardColor, 0.05);
      Color esb = Colors.green[500] ?? Colors.green;
      Color osb = Colors.green[300] ?? Colors.green;
      Color sb = i.isEven ? esb : osb;

      return EditTableRow(
        onEdit: () => ConfirmFutureDialog(
          onStatusConfirmFuture: () {
            // catcher if the session was updated while the dialog was open
            JudgingSession? updatedSession =
                Provider.of<JudgingSessionProvider>(context, listen: false).getSessionBySessionNumber(
              s.sessionNumber,
            );

            s = updatedSession ?? s;

            return Provider.of<JudgingSessionProvider>(context, listen: false).insertJudgingSession(
              s.sessionNumber,
              JudgingSession(
                sessionNumber: _sessionNumberController.text,
                startTime: _selectedStartTime.value,
                endTime: _selectedEndTime.value,
                completed: _selectedCompleted.value,
                judgingSessionPods: s.judgingSessionPods,
                category: s.category,
              ),
            );
          },
          style: ConfirmDialogStyle.warn(
            title: "Edit Session: ${s.sessionNumber}",
            message: Selector<JudgingSessionProvider, JudgingSession?>(
              selector: (context, provider) => provider.getSessionBySessionNumber(s.sessionNumber),
              builder: (context, session, _) {
                if (session == null) {
                  return const Text("Session not found");
                }
                return EditSessionWidget(
                  judgingSession: session,
                  sessionNumberController: _sessionNumberController,
                  startTime: _selectedStartTime,
                  endTime: _selectedEndTime,
                  completed: _selectedCompleted,
                );
              },
            ),
          ),
        ).show(context),
        onDelete: () => OnDeleteSession(sessionNumber: s.sessionNumber).call(context),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        cells: [
          BaseTableCell(
            child: Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
              selector: (context, provider) => provider.getSessionMessages(s.sessionNumber),
              builder: (context, integrityMessages, _) {
                return Center(child: IconTooltipIntegrityCheck(messages: integrityMessages));
              },
            ),
            flex: 1,
          ),
          BaseTableCell(
            child: Center(
              child: CircleAvatar(
                child: Text(s.sessionNumber),
                backgroundColor: s.completed ? Colors.green : Colors.red,
              ),
            ),
            flex: 1,
          ),
          BaseTableCell(
            child: Center(child: Text(s.startTime.toString())),
            flex: 1,
          ),
          BaseTableCell(
            child: _judgingSessionPods(
              context,
              s.judgingSessionPods,
              backgroundColor: c,
              submittedColor: sb,
              isSessionComplete: s.completed,
            ),
            flex: 4,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":judging:sessions",
        ":judging:pods",
        ":teams",
        ":tournament:integrity_messages",
      ],
      child: Selector<JudgingSessionProvider, List<JudgingSession>>(
        selector: (_, p) => p.judgingSessions,
        shouldRebuild: (previous, next) => !listEquals(previous, next),
        builder: (context, judgingSessions, _) {
          return Column(
            children: [
              // info banner
              JudgingInfoBanner(
                judgingSessions: judgingSessions,
              ),
              Expanded(
                child: EditTable(
                  onAdd: () => OnAddSession().call(context),
                  headers: [
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Integrity", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Session", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 1,
                    ),
                    const BaseTableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text("Pods", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      flex: 4,
                    ),
                  ],
                  rows: _rows(context, judgingSessions),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
