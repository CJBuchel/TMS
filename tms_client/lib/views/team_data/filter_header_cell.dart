import 'package:flutter/material.dart';
import 'package:tms/widgets/tables/base_table.dart';

class FilterColumn extends BaseTableCell {
  final String label;
  final bool show;
  final int? flex;
  final Function(String filter)? onFilterChanged;

  FilterColumn({
    required this.label,
    required this.show,
    this.onFilterChanged,
    this.flex,
  }) : super(
          flex: flex,
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: TextField(
                      onChanged: (v) => onFilterChanged?.call(v),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Center(
                          child: Text(
                            "Contains",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}
