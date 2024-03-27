import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  final Color? accentColors;
  final Color? backgroundColor;
  final String? matchNumber;
  final String? sessionNumber;
  final String? teamNumber;
  final String message;

  const MessageContainer({
    Key? key,
    this.accentColors,
    this.backgroundColor,
    this.matchNumber,
    this.teamNumber,
    this.sessionNumber,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String identifier = "";
    String team = "";
    String msg = message;

    if (sessionNumber != null) {
      identifier = "Session $sessionNumber - ";
    } else if (matchNumber != null) {
      identifier = "Match $matchNumber - ";
    }

    if (teamNumber != null) {
      team = "Team $teamNumber: ";
    }

    String msgText = "$identifier$team$msg";

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: accentColors,
        ),
        title: Center(
          child: Text(
            msgText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Tooltip(
          message: msgText,
          child: Icon(
            Icons.notifications_active_outlined,
            color: accentColors,
          ),
        ),
      ),
    );
  }
}
