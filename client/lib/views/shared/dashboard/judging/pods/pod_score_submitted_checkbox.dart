import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class PodScoreSubmittedCheckbox extends StatefulWidget {
  final JudgingPod pod;
  final JudgingSession session;
  final Function(JudgingSession) onPodUpdate;

  const PodScoreSubmittedCheckbox({
    Key? key,
    required this.pod,
    required this.session,
    required this.onPodUpdate,
  }) : super(key: key);

  @override
  State<PodScoreSubmittedCheckbox> createState() => _ScoreSubmittedCheckboxState();
}

class _ScoreSubmittedCheckboxState extends State<PodScoreSubmittedCheckbox> {
  void _toggleState(bool? value) {
    if (mounted && value != null) {
      final index = widget.session.judgingPods.indexWhere((element) => element.pod == widget.pod.pod);
      if (index != -1) {
        JudgingSession updatedSession = widget.session;
        setState(() {
          updatedSession.judgingPods[index].scoreSubmitted = value;
          widget.onPodUpdate(updatedSession);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.pod.scoreSubmitted,
      onChanged: (value) {
        _toggleState(value);
      },
    );
  }
}
