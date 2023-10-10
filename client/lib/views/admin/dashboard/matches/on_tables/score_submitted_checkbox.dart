import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class ScoreSubmittedCheckbox extends StatefulWidget {
  final OnTable onTable;
  final GameMatch match;
  final Function(GameMatch) onTableUpdate;

  const ScoreSubmittedCheckbox({
    Key? key,
    required this.onTable,
    required this.match,
    required this.onTableUpdate,
  }) : super(key: key);

  @override
  State<ScoreSubmittedCheckbox> createState() => _ScoreSubmittedCheckboxState();
}

class _ScoreSubmittedCheckboxState extends State<ScoreSubmittedCheckbox> {
  @override
  void initState() {
    super.initState();
  }

  void _toggleState(bool? value) {
    if (mounted && value != null) {
      final index = widget.match.matchTables.indexWhere((element) => element.table == widget.onTable.table);
      if (index != -1) {
        GameMatch updatedMatch = widget.match;
        setState(() {
          updatedMatch.matchTables[index].scoreSubmitted = value;
          widget.onTableUpdate(updatedMatch);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.onTable.scoreSubmitted,
      onChanged: (value) {
        _toggleState(value);
      },
    );
  }
}
