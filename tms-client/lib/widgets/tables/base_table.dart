import 'package:flutter/material.dart';

class BaseTableCell {
  final Widget child;
  final int? flex;

  const BaseTableCell({
    required this.child,
    this.flex,
  });
}

class BaseTableRow {
  final List<BaseTableCell> cells;
  final BoxDecoration? decoration;

  const BaseTableRow({
    required this.cells,
    // optional per row decoration
    this.decoration,
  });
}

class BaseTable extends StatelessWidget {
  final List<BaseTableCell>? headers;
  final List<BaseTableRow> rows;

  final BoxDecoration? headerDecoration;

  const BaseTable({
    Key? key,
    this.headers,
    required this.rows,

    // misc
    this.headerDecoration,
  }) : super(key: key);

  Widget cellWidget(Widget child, int flex) {
    return Expanded(
      child: child,
      flex: flex,
    );
  }

  Widget headerWidgets() {
    if (headers == null) {
      return const SizedBox.shrink();
    } else {
      return Row(
        children: headers!.map((cell) {
          return cellWidget(cell.child, cell.flex ?? 1);
        }).toList(),
      );
    }
  }

  Widget tableRowWidget(BaseTableRow row) {
    return Row(
      children: [
        for (var cell in row.cells) cellWidget(cell.child, cell.flex ?? 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: headerDecoration,
          child: headerWidgets(),
        ),
        Flexible(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: rows[index].decoration,
                child: tableRowWidget(rows[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
