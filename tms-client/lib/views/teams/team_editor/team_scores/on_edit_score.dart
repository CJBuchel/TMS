import 'package:flutter/material.dart';
import 'package:tms/models/team_score_sheet.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';

class OnEditScore {
  final BuildContext context;
  final TeamScoreSheet score;

  OnEditScore({
    required this.context,
    required this.score,
  });

  Widget _textCell(String title, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            text,
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  void call() {
    ConfirmFutureDialog(
      style: ConfirmDialogStyle.warn(
        title: 'Edit Score',
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // non edit fields
            _textCell('Blueprint: ', score.scoreSheet.blueprintTitle),
            _textCell('Timestamp: ', tmsDateTimeToString(score.scoreSheet.timestamp)),
            _textCell('GP: ', score.scoreSheet.gp),
            _textCell('Round: ', score.scoreSheet.round.toString()),
            _textCell('Private Comment: ', score.scoreSheet.privateComment),
            _textCell('Modified: ', score.scoreSheet.modified.toString()),
            _textCell('Modified By: ', score.scoreSheet.modifiedBy ?? ''),
            _textCell('Score: ', score.scoreSheet.score.toString()),
            // divider
            const Divider(),
            // edit fields
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Table', border: OutlineInputBorder()),
                controller: TextEditingController(text: score.scoreSheet.table),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Referee', border: OutlineInputBorder()),
                controller: TextEditingController(text: score.scoreSheet.referee),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Match Number', border: OutlineInputBorder()),
                controller: TextEditingController(text: score.scoreSheet.matchNumber ?? ''),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No Show: '),
                  LiveCheckbox(
                    defaultValue: score.scoreSheet.noShow,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Agnostic: '),
                  LiveCheckbox(
                    defaultValue: score.scoreSheet.isAgnostic,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Answers: '),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
