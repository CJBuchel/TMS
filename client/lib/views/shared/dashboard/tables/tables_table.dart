import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/tables/add_table.dart';
import 'package:tms/views/shared/dashboard/tables/tables_edit_row.dart';

class TablesTable extends StatelessWidget {
  final ValueNotifier<Event> event;
  const TablesTable({Key? key, required this.event}) : super(key: key);

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
          child: _styledTextCell("Table"),
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
            AddTableButton(event: event),
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
    for (final table in event.tables) {
      rows.add(Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: TablesEditRow(
          table: table,
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
