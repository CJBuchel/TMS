import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/team_editor.dart';
import 'package:tms/views/admin/dashboard/teams/team_select/team_select.dart';

class Teams extends StatelessWidget {
  Teams({Key? key}) : super(key: key);
  final ValueNotifier<String?> _selectedTeam = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // team selector list (left side)
            Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth * 0.3, // 30%

              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                    width: 1,
                  ),
                ),
              ),

              child: TeamSelect(
                onTeamSelected: (t) {
                  _selectedTeam.value = t;
                },
              ),
            ),

            // team edit (right side)
            Expanded(
              child: TeamEditor(
                selectedTeamNumber: _selectedTeam,
              ),
            ),
          ],
        );
      },
    );
  }
}
