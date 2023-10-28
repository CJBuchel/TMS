import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/shared/dashboard/teams/team_editor/team_editor.dart';
import 'package:tms/views/shared/dashboard/teams/team_select/team_select.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class Teams extends StatefulWidget {
  const Teams({Key? key}) : super(key: key);

  @override
  State<Teams> createState() => _TeamsState();
}

class _TeamsState extends State<Teams> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  // use value notifiers because we don't want to rebuild on every change (team dashboard can get messy)
  final ValueNotifier<List<Team>> _teamsNotifier = ValueNotifier<List<Team>>([]);
  final ValueNotifier<String?> _selectedTeamNumberNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<Team?> _selectedTeamNotifier = ValueNotifier<Team?>(null);

  set _setSelectedTeamNumber(String? t) {
    _selectedTeamNumberNotifier.value = t;
  }

  void _setSelectedTeam() {
    String? teamNumber = _selectedTeamNumberNotifier.value;
    for (Team t in _teamsNotifier.value) {
      if (t.teamNumber == teamNumber) {
        _selectedTeamNotifier.value = t;
        break;
      }
    }
  }

  set _setTeams(List<Team> teams) {
    for (Team t in teams) {
      if (t.teamNumber == _selectedTeamNumberNotifier.value) {
        _selectedTeamNotifier.value = t;
        break;
      }
    }
    _teamsNotifier.value = teams;
  }

  void _setData() {
    getTeams().then((t) => _setTeams = t);
  }

  void _forceFetchTeams() {
    getTeamsRequest().then((value) {
      if (value.item1 != HttpStatus.ok) {
        showNetworkError(value.item1, context, subMessage: "Failed to fetch teams");
      } else {
        _setTeams = sortTeamsByNumber(value.item2);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _setData();
    onTeamsUpdate((t) => _setTeams = t);

    // add listener to the team number
    _selectedTeamNumberNotifier.addListener(() {
      _setSelectedTeam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // team selector list (left side)
            SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth * 0.3, // 30%

              child: TeamSelect(
                teams: _teamsNotifier,
                onForceReload: () => _forceFetchTeams(),
                onTeamSelected: (t) {
                  _setSelectedTeamNumber = t;
                },
              ),
            ),

            // team edit (right side)
            Expanded(
              child: TeamEditor(
                selectedTeamNumberNotifier: _selectedTeamNumberNotifier,
                selectedTeamNotifier: _selectedTeamNotifier,
              ),
            ),
          ],
        );
      },
    );
  }
}
