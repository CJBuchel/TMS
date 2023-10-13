import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/info_banner.dart';

class TeamEditor extends StatefulWidget {
  final Team team;
  final Event? event;
  final List<JudgingSession> sessions;
  final List<GameMatch> matches;
  const TeamEditor({
    Key? key,
    required this.team,
    required this.event,
    required this.sessions,
    required this.matches,
  }) : super(key: key);

  @override
  State<TeamEditor> createState() => _TeamEditorState();
}

class _TeamEditorState extends State<TeamEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Container(
            width: constraints.maxWidth,
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            child: TeamInfoBanner(
              team: widget.team,
              sessions: widget.sessions,
              matches: widget.matches,
              event: widget.event,
            ),
          ),
        ],
      );
    });
  }
}
