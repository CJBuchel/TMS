import 'package:flutter/material.dart';

class TmsTableCell extends StatelessWidget {
  final Widget child;
  final int? flex;

  const TmsTableCell({required this.child, this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 1,
      child: Center(
        child: child,
      ),
    );
  }
}

class TmsTableRow extends StatelessWidget {
  final List<TmsTableCell> children;

  const TmsTableRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.map((e) {
        return Expanded(
          flex: e.flex ?? 1,
          child: Center(
            child: e.child,
          ),
        );
      }).toList(),
    );
  }
}

class TmsTable extends StatelessWidget {
  final TmsTableRow? header;
  final List<TmsTableRow> rows;
  final bool isHeaderScrollable; // header is not scrollable

  const TmsTable({
    Key? key,
    this.header,
    required this.rows,
    this.isHeaderScrollable = false,
  }) : super(key: key);

  Widget _header() {
    if (header == null) {
      return const SizedBox();
    }
    return this.header!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return rows[index];
            },
          ),
        ),
      ],
    );
  }
}
