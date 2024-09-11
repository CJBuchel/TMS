import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/pods/add_pod.dart';
import 'package:tms/views/shared/dashboard/pods/pods_edit_row.dart';

class PodsTable extends StatelessWidget {
  final ValueNotifier<Event> event;
  const PodsTable({Key? key, required this.event}) : super(key: key);

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

  Widget _getHeaderRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _styledTextCell("Delete"),
        ),
        Expanded(
          flex: 2,
          child: _styledTextCell("Pod"),
        ),
        Expanded(
          flex: 1,
          child: _styledTextCell("Edit"),
        ),
      ],
    );
  }

  Widget _getFooterRow(Event event) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _styledCell(
            AddPodButton(event: event),
          ),
        ),
        const Expanded(
          flex: 3,
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  List<Widget> _getRows(Event event) {
    final rows = <Widget>[];
    for (final pod in event.pods) {
      rows.add(Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: PodsEditRow(
          pod: pod,
          event: event,
        ),
      ));
    }

    rows.add(_getFooterRow(event));
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: event,
      builder: (context, event, _) {
        return Column(
          children: [
            SizedBox(
              height: 50,
              child: _getHeaderRow(),
            ),
            Expanded(
              child: ListView(
                children: _getRows(event),
              ),
            ),
          ],
        );
      },
    );
  }
}
