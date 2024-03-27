import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/pods/delete_pod.dart';
import 'package:tms/views/shared/dashboard/pods/edit_pod.dart';

class PodsEditRow extends StatelessWidget {
  final Event event;
  final String pod;
  const PodsEditRow({
    Key? key,
    required this.event,
    required this.pod,
  }) : super(key: key);

  Widget _styledCell(Widget inner, {Color? color}) {
    return Container(
      color: color,
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _styledTextCell(String label, {Color? color, Color? textColor}) {
    return _styledCell(
      color: color,
      Text(
        label,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _styledCell(
            DeletePodButton(event: event, pod: pod),
          ),
        ),
        Expanded(
          flex: 2,
          child: _styledTextCell(pod),
        ),
        Expanded(
          flex: 1,
          child: _styledCell(
            EditPodButton(event: event, pod: pod),
          ),
        ),
      ],
    );
  }
}
