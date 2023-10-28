import 'package:flutter/material.dart';

import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/match_scores/edit_score_dialog.dart';

class EditScoreButton extends StatelessWidget {
  final Team team;
  final int index;
  final Function()? onUpdate;
  const EditScoreButton({
    Key? key,
    required this.team,
    required this.index,
    this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return EditScoreDialog(team: team, index: index);
          },
        );
      },
      icon: const Icon(Icons.edit, color: Colors.blue),
    );
  }
}
