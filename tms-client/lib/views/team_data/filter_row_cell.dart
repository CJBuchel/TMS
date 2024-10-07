import 'package:flutter/material.dart';
import 'package:tms/widgets/tables/base_table.dart';

class FilterRowCell extends BaseTableCell {
  final BuildContext context;
  final String text;
  final int? flex;
  final Color? color;

  FilterRowCell({
    required this.context,
    required this.text,
    this.flex,
    this.color,
  }) : super(
          flex: flex,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
}
