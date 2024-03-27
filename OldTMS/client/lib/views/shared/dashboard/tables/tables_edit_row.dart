import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/tables/delete_table.dart';
import 'package:tms/views/shared/dashboard/tables/edit_table.dart';

class TablesEditRow extends StatelessWidget {
  final Event event;
  final String table;
  const TablesEditRow({
    Key? key,
    required this.event,
    required this.table,
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
            DeleteTableButton(event: event, table: table),
          ),
        ),
        Expanded(
          flex: 2,
          child: _styledTextCell(table),
        ),
        Expanded(
          flex: 1,
          child: _styledCell(
            EditTableButton(event: event, table: table),
          ),
        ),
      ],
    );
  }
}
