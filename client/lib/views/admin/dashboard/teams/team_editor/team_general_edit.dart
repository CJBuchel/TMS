import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/delete_team_button.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class TeamGeneralEdit extends StatefulWidget {
  final String teamNumber;
  final Function() onTeamDelete;
  final Function(Team t) onUpdate;

  const TeamGeneralEdit({
    Key? key,
    required this.teamNumber,
    required this.onTeamDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<TeamGeneralEdit> createState() => _TeamGeneralEditState();
}

class _TeamGeneralEditState extends State<TeamGeneralEdit> {
  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamAffiliationController = TextEditingController();
  final TextEditingController _teamIdController = TextEditingController();

  Team? _team;

  void _updateTeam() {
    if (_team != null) {
      _team!.teamNumber = _teamNumberController.text;
      _team!.teamName = _teamNameController.text;
      _team!.teamAffiliation = _teamAffiliationController.text;
      _team!.teamId = _teamIdController.text;

      updateTeamRequest(widget.teamNumber, _team!).then((res) {
        if (res != HttpStatus.ok) {
          showNetworkError(res, context, subMessage: "Failed to update team ${widget.teamNumber}");
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("Team ${widget.teamNumber} updated"),
          ));
        }
        _fetchTeam();
        widget.onUpdate(_team!);
      });
    }
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

  void _fetchTeam() {
    getTeamRequest(widget.teamNumber).then((res) {
      if (res.item1 == HttpStatus.ok) {
        if (res.item2 != null) _setTeam = res.item2!;
      }
    });
  }

  @override
  void didUpdateWidget(covariant TeamGeneralEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamNumber != widget.teamNumber) {
      _fetchTeam();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeam();
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
            teamNumber: _team?.teamNumber ?? "",
            onTeamDelete: () {
              _fetchTeam();
              widget.onTeamDelete();
            },
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
    if (_team == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
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
}
