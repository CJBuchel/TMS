import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/providers/judging_pod_provider.dart';
import 'package:tms/providers/judging_session_provider.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/views/judging_sessions/edit_session/add_pod_widget.dart';
import 'package:tms/views/judging_sessions/edit_session/edit_pod_widget.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/dialogs/dialog_style.dart';
import 'package:tms/widgets/edit_time.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class _AvailableData {
  final List<String> availablePods;
  final List<Team> availableTeams;

  _AvailableData({
    required this.availablePods,
    required this.availableTeams,
  });
}

class EditSessionWidget extends StatelessWidget {
  final JudgingSession judgingSession;
  final TextEditingController sessionNumberController;
  final ValueNotifier<TmsDateTime> startTime;
  final ValueNotifier<TmsDateTime> endTime;
  final ValueNotifier<bool> completed;

  EditSessionWidget({
    required this.judgingSession,
    required this.sessionNumberController,
    required this.startTime,
    required this.endTime,
    required this.completed,
  });

  // editable team, table, submitted
  final ValueNotifier<String> _selectedPod = ValueNotifier<String>("");
  final ValueNotifier<Team> _selectedTeam = ValueNotifier<Team>(
    const Team(teamNumber: "", name: "", ranking: 0, affiliation: ""),
  );

  // scores submitted
  final ValueNotifier<bool> _coreValuesSubmitted = ValueNotifier(false);
  final ValueNotifier<bool> _innovationSubmitted = ValueNotifier(false);
  final ValueNotifier<bool> _robotDesignSubmitted = ValueNotifier(false);

  // heh, padded cell
  BaseTableCell _paddedCell(Widget child) {
    return BaseTableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sessionNumberController.text = judgingSession.sessionNumber;
    startTime.value = judgingSession.startTime;
    endTime.value = judgingSession.endTime;
    completed.value = judgingSession.completed;

    return Selector2<JudgingPodProvider, TeamsProvider, _AvailableData>(
      selector: (_, podProvider, teamsProvider) {
        // get pods not referenced in the session
        List<String> availablePods = podProvider.podNames
            .where((pod) => !judgingSession.judgingSessionPods.any((data) => data.podName == pod))
            .map((pod) => pod)
            .toList();

        // get teams not referenced in the session
        List<Team> availableTeams = teamsProvider.teams
            .where((team) => !judgingSession.judgingSessionPods.any((data) => data.teamNumber == team.teamNumber))
            .toList();

        return _AvailableData(
          availablePods: availablePods,
          availableTeams: availableTeams,
        );
      },
      builder: (context, data, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: sessionNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                  labelText: "Session Number",
                  hintText: "Enter Session Number",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: EditTimeWidget(
                label: "Start Time",
                initialTime: startTime.value,
                onChanged: (t) => startTime.value = t,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: EditTimeWidget(
                label: "End Time",
                initialTime: endTime.value,
                onChanged: (t) => endTime.value = t,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Completed: "),
                  LiveCheckbox(
                    defaultValue: completed.value,
                    onChanged: (v) => completed.value = v,
                  ),
                ],
              ),
            ),
            const Divider(),
            EditTable(
              onAdd: () {
                _selectedPod.value = data.availablePods.firstOrNull ?? "";
                _selectedTeam.value = data.availableTeams.firstOrNull ??
                    const Team(teamNumber: "", name: "", ranking: 0, affiliation: "");

                ConfirmFutureDialog(
                  onStatusConfirmFuture: () {
                    if (_selectedTeam.value.teamNumber.isEmpty || _selectedPod.value.isEmpty) {
                      return Future.value(HttpStatus.badRequest);
                    } else {
                      return Provider.of<JudgingSessionProvider>(context, listen: false).addPodToSession(
                        _selectedPod.value,
                        _selectedTeam.value.teamNumber,
                        judgingSession.sessionNumber,
                      );
                    }
                  },
                  style: DialogStyle.success(
                    title: "Add Pod to Session: ${judgingSession.sessionNumber}",
                    message: AddPodWidget(
                      availablePods: data.availablePods,
                      availableTeams: data.availableTeams,
                      selectedPod: _selectedPod,
                      selectedTeam: _selectedTeam,
                    ),
                  ),
                ).show(context);
              },
              headers: [
                _paddedCell(const Text("Pod")),
                _paddedCell(const Text("Team")),
                _paddedCell(const Text("Core Values")),
                _paddedCell(const Text("Innovation")),
                _paddedCell(const Text("Robot Design")),
              ],
              rows: judgingSession.judgingSessionPods.map((jsp) {
                return EditTableRow(
                  onEdit: () {
                    _selectedPod.value = jsp.podName;
                    _selectedTeam.value = Provider.of<TeamsProvider>(context, listen: false).getTeam(jsp.teamNumber);
                    _coreValuesSubmitted.value = jsp.coreValuesSubmitted;
                    _innovationSubmitted.value = jsp.innovationSubmitted;
                    _robotDesignSubmitted.value = jsp.robotDesignSubmitted;

                    ConfirmFutureDialog(
                      onStatusConfirmFuture: () {
                        if (_selectedTeam.value.teamNumber.isEmpty || _selectedPod.value.isEmpty) {
                          return Future.value(HttpStatus.badRequest);
                        } else {
                          return Provider.of<JudgingSessionProvider>(context, listen: false).updatePodInSession(
                            originPod: jsp.podName,
                            originSessionNumber: judgingSession.sessionNumber,
                            updatedPod: JudgingSessionPod(
                              podName: _selectedPod.value,
                              teamNumber: _selectedTeam.value.teamNumber,
                              coreValuesSubmitted: _coreValuesSubmitted.value,
                              innovationSubmitted: _innovationSubmitted.value,
                              robotDesignSubmitted: _robotDesignSubmitted.value,
                            ),
                          );
                        }
                      },
                      style: DialogStyle.success(
                        title: "Edit team ${jsp.teamNumber} in pod ${jsp.podName}",
                        message: EditPodWidget(
                          availablePods: data.availablePods,
                          availableTeams: data.availableTeams,
                          selectedPod: _selectedPod,
                          selectedTeam: _selectedTeam,
                          coreValuesSubmitted: _coreValuesSubmitted,
                          innovationSubmitted: _innovationSubmitted,
                          robotDesignSubmitted: _robotDesignSubmitted,
                        ),
                      ),
                    ).show(context);
                  },
                  onDelete: () {
                    ConfirmFutureDialog(
                      style: DialogStyle.error(
                        title: "Delete Pod: ${jsp.podName}",
                        message: const Text("Are you sure you want to delete this pod?"),
                      ),
                      onStatusConfirmFuture: () {
                        return Provider.of<JudgingSessionProvider>(context, listen: false).removePodFromSession(
                          jsp.podName,
                          judgingSession.sessionNumber,
                        );
                      },
                    ).show(context);
                  },
                  cells: [
                    _paddedCell(Text(jsp.podName)),
                    _paddedCell(Text(jsp.teamNumber)),
                    _paddedCell(Text(jsp.coreValuesSubmitted.toString())),
                    _paddedCell(Text(jsp.innovationSubmitted.toString())),
                    _paddedCell(Text(jsp.robotDesignSubmitted.toString())),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
