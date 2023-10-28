import 'package:flutter/material.dart';

class TDColumn {
  String label;
  bool show = false;
  int flex = 1;
  String filter = "";

  TDColumn({
    required this.label,
    required this.show,
    required this.flex,
  });
}

enum TDCellType {
  text,
  number,
  widget,
}

class TDCell {
  TDCellType type;
  dynamic value;
  Color? color;

  TDCell({
    required this.type,
    this.value,
    this.color,
  });

  factory TDCell.text(String value, {Color? color}) {
    return TDCell(
      type: TDCellType.text,
      value: value,
      color: color,
    );
  }

  factory TDCell.number(double value, {Color? color}) {
    return TDCell(
      type: TDCellType.number,
      value: value,
      color: color,
    );
  }

  factory TDCell.widget(Widget value, {Color? color}) {
    return TDCell(
      type: TDCellType.widget,
      value: value,
      color: color,
    );
  }

  Widget _cell({Widget? child, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Center(child: child),
    );
  }

  String get text {
    switch (type) {
      case TDCellType.text:
        return value;
      case TDCellType.number:
        return value.toString();
      case TDCellType.widget:
        return "";
    }
  }

  Widget _get() {
    switch (type) {
      case TDCellType.widget:
        return value;
      default:
        return Text(text);
    }
  }

  Widget get widget {
    return _cell(
      color: color,
      child: _get(),
    );
  }

  int compare(TDCell cell) {
    switch (type) {
      case TDCellType.text:
        return (value as String).compareTo(cell.value);
      case TDCellType.number:
        return (value as double).compareTo(cell.value);
      case TDCellType.widget:
        return 0;
    }
  }

  bool filter(String filter) {
    switch (type) {
      case TDCellType.text:
        return (value as String).toLowerCase().contains(filter.toLowerCase());
      case TDCellType.number:
        return (value as double) == double.tryParse(filter);
      case TDCellType.widget:
        return false;
    }
  }
}

class TDRow {
  Color? rowColor;
  double? height;
  List<TDCell> cells = [];

  TDRow({
    this.rowColor,
    this.height,
    required this.cells,
  });
}
