import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/delete_team_button.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class TeamGeneralEdit extends StatefulWidget {
  final String teamNumber;
  final Function() onTeamDelete;

  const TeamGeneralEdit({
    Key? key,
    required this.teamNumber,
    required this.onTeamDelete,
  }) : super(key: key);

  @override
  State<TeamGeneralEdit> createState() => _TeamGeneralEditState();
}

class _TeamGeneralEditState extends State<TeamGeneralEdit> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamAffiliationController = TextEditingController();
  final TextEditingController _teamIdController = TextEditingController();

  Team _team = LocalDatabaseMixin.teamDefault();

  void _updateTeam() {
    _team.teamNumber = _teamNumberController.text;
    _team.teamName = _teamNameController.text;
    _team.teamAffiliation = _teamAffiliationController.text;
    _team.teamId = _teamIdController.text;

    updateTeamRequest(widget.teamNumber, _team).then((res) {
      if (res != HttpStatus.ok) {
        showNetworkError(res, context, subMessage: "Failed to update team ${widget.teamNumber}");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text("Team ${widget.teamNumber} updated"),
        ));
      }
    });
  }

  set _setTeam(Team t) {
    if (mounted) {
      setState(() {
        _team = t;
        _teamNumberController.text = t.teamNumber;
        _teamNameController.text = t.teamName;
        _teamAffiliationController.text = t.teamAffiliation;
        _teamIdController.text = t.teamId;
      });
    }
  }

  set _setTeams(List<Team> teams) {
    if (mounted) {
      for (Team t in teams) {
        if (t.teamNumber == widget.teamNumber) {
          _setTeam = t;
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onTeamUpdate((t) => _setTeam = t);
    onTeamsUpdate((teams) => _setTeams = teams);
  }

  Widget _paddedInner(Widget inner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: inner,
    );
  }

  Widget _teamNumber() {
    return TextField(
      controller: _teamNumberController,
      decoration: const InputDecoration(
        labelText: "Team Number",
        hintText: "Enter team number",
      ),
    );
  }

  Widget _teamName() {
    return TextField(
      controller: _teamNameController,
      decoration: const InputDecoration(
        labelText: "Team Name",
        hintText: "Enter team name",
      ),
    );
  }

  Widget _teamAffiliation() {
    return TextField(
      controller: _teamAffiliationController,
      decoration: const InputDecoration(
        labelText: "Team Affiliation",
        hintText: "Enter team affiliation",
      ),
    );
  }

  Widget _teamId() {
    return TextField(
      controller: _teamIdController,
      decoration: const InputDecoration(
        labelText: "Team ID",
        hintText: "Enter team ID",
      ),
    );
  }

  Widget _updateButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: DeleteTeamButton(
            teamNumber: _team.teamNumber,
            onTeamDelete: widget.onTeamDelete,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _updateTeam();
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text("Update"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _paddedInner(_teamNumber()),
        _paddedInner(_teamName()),
        _paddedInner(_teamAffiliation()),
        _paddedInner(_teamId()),
        _paddedInner(_updateButtons()),
      ],
    );
  }
}
