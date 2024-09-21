import 'package:flutter/material.dart';
import 'package:tms/widgets/tables/base_table.dart';

class EditTableRow extends BaseTableRow {
  final Key? key;

  // optional per row onEdit & onDelete
  final Function()? onDelete;
  final Function()? onEdit;

  EditTableRow({
    this.key,
    required List<BaseTableCell> cells,
    BoxDecoration? decoration,
    this.onDelete,
    this.onEdit,
  }) : super(cells: cells, decoration: decoration);
}

class EditTable extends BaseTable {
  final List<EditTableRow> rows;
  final Function(int index, Key? key)? onDelete;
  final Function(int index, Key? key)? onEdit;
  final Function()? onAdd;

  BaseTableCell _iconButtonCell({Function()? onPressed, required Widget icon}) {
    return BaseTableCell(
      child: Center(
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    );
  }

  EditTable({
    List<BaseTableCell>? headers,
    required this.rows,
    this.onDelete,
    this.onEdit,
    this.onAdd,
    BoxDecoration? headerDecoration,
  }) : super(headers: headers, rows: rows, headerDecoration: headerDecoration) {
    // add blank to start and end of headers
    if (headers != null) {
      headers.insert(0, const BaseTableCell(child: SizedBox.shrink()));
      headers.add(const BaseTableCell(child: SizedBox.shrink()));
    }

    // add delete and edit buttons to each row
    for (var row in rows) {
      row.cells.insert(
        0,
        _iconButtonCell(
          onPressed: () {
            if (row.onDelete != null) {
              row.onDelete?.call();
            } else if (onDelete != null) {
              onDelete!(rows.indexOf(row), row.key);
            }
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      );

      row.cells.add(
        _iconButtonCell(
          onPressed: () {
            if (row.onEdit != null) {
              row.onEdit?.call();
            } else if (onEdit != null) {
              onEdit!(rows.indexOf(row), row.key);
            }
          },
          icon: const Icon(Icons.edit, color: Colors.blue),
        ),
      );
    }

    // add final add button as row
    var lastRow = rows.lastOrNull;

    if (lastRow != null) {
      rows.add(EditTableRow(
        cells: [
          _iconButtonCell(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.green),
          ),
          ...List.generate(lastRow.cells.length - 1, (index) {
            return BaseTableCell(
              child: const SizedBox.shrink(),
              flex: lastRow.cells[index].flex ?? 1,
            );
          }),
        ],
      ));
    } else {
      rows.add(EditTableRow(
        cells: [
          _iconButtonCell(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: onAdd,
          ),
        ],
      ));
    }
  }
}
