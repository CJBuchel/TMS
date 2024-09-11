import 'package:flutter/material.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table_types.dart';

class TDTable extends StatefulWidget {
  final double? headerHeight;
  final bool showHeader;
  final bool showFilterRow;

  final List<TDColumn> columns;
  final List<TDRow> rows;

  const TDTable({
    Key? key,
    this.headerHeight,
    this.showHeader = true,
    this.showFilterRow = false,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  @override
  State<TDTable> createState() => _TDTableState();
}

class _TDTableState extends State<TDTable> {
  List<TDRow> _filteredRows = [];

  void _applyFilter() {
    List<TDRow> filteredRows = [];

    for (TDRow r in widget.rows) {
      bool show = true;

      for (int i = 0; (i < widget.columns.length) && show; i++) {
        TDColumn c = widget.columns[i];

        if (c.show && c.filter.isNotEmpty) {
          if (i < r.cells.length) {
            TDCell cell = r.cells[i];
            if (!cell.filter(c.filter)) {
              show = false;
            }
          }
        }
      }

      if (show) {
        filteredRows.add(r);
      }
    }

    setState(() {
      _filteredRows = filteredRows;
    });
  }

  @override
  void didUpdateWidget(covariant TDTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyFilter();
  }

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  Widget _header() {
    List<Widget> columnCells = [];

    for (TDColumn c in widget.columns) {
      if (c.show) {
        columnCells.add(
          Expanded(
            flex: c.flex,
            child: Center(child: Text(c.label)),
          ),
        );
      }
    }

    return Row(
      children: columnCells,
    );
  }

  Widget _row(TDRow r) {
    List<Widget> rowCells = [];
    for (int i = 0; (i < widget.columns.length); i++) {
      TDColumn c = widget.columns[i];

      Widget? cell;

      if (i < r.cells.length) {
        cell = r.cells[i].widget;
      } else {
        cell = const SizedBox();
      }

      if (c.show) {
        rowCells.add(
          Expanded(
            flex: c.flex,
            child: cell,
          ),
        );
      }
    }

    return Container(
      height: r.height,
      color: r.rowColor,
      child: Row(
        children: rowCells,
      ),
    );
  }

  Widget _rows() {
    return ListView.builder(
      itemCount: _filteredRows.length,
      itemBuilder: (context, index) {
        return _row(_filteredRows[index]);
      },
    );
  }

  Widget _filterRow() {
    List<Widget> filterCells = [];

    for (TDColumn c in widget.columns) {
      if (c.show) {
        filterCells.add(
          Expanded(
            flex: c.flex,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contains',
              ),
              onChanged: (value) {
                c.filter = value;
                _applyFilter();
              },
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: widget.headerHeight ?? 50,
      child: Row(
        children: filterCells,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.headerHeight ?? 50,
          child: _header(),
        ),
        if (widget.showFilterRow) _filterRow(),
        Expanded(
          child: _rows(),
        ),
      ],
    );
  }
}
