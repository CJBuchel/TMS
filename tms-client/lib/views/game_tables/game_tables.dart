import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_table.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class GameTables extends StatelessWidget {
  final TextEditingController _tableController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    BaseTableCell _buildCell(Widget child) {
      return BaseTableCell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: child,
          ),
        ),
      );
    }

    List<EditTableRow> _rows(BuildContext context, List<GameTable> tables) {
      return tables.map((table) {
        return EditTableRow(
          onEdit: () {
            _tableController.text = table.tableName;
            ConfirmFutureDialog(
              onStatusConfirmFuture: () {
                String? tableId = Provider.of<GameTableProvider>(context, listen: false).getIdFromTableName(
                  table.tableName,
                );
                if (tableId == null) {
                  return Future.value(HttpStatus.notFound);
                } else {
                  return Provider.of<GameTableProvider>(context, listen: false).insertTable(
                    tableId,
                    _tableController.text,
                  );
                }
              },
              style: ConfirmDialogStyle.warn(
                title: "Edit Table: ${table.tableName}",
                message: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tableController,
                      decoration: const InputDecoration(
                        hintText: "Table Name",
                      ),
                    ),
                  ],
                ),
              ),
            ).show(context);
          },
          onDelete: () {
            ConfirmFutureDialog(
              onStatusConfirmFuture: () {
                String? tableId = Provider.of<GameTableProvider>(context, listen: false).getIdFromTableName(
                  table.tableName,
                );
                if (tableId == null) {
                  return Future.value(HttpStatus.notFound);
                } else {
                  return Provider.of<GameTableProvider>(context, listen: false).removeTable(tableId);
                }
              },
              style: ConfirmDialogStyle.error(
                title: "Delete Table: ${table.tableName}",
                message: const Text("Are you sure you want to delete this table?"),
              ),
            ).show(context);
          },
          cells: [
            _buildCell(Text(table.tableName)),
          ],
        );
      }).toList();
    }

    return EchoTreeLifetime(
      trees: [":robot_game:tables"],
      child: Selector<GameTableProvider, List<GameTable>>(
        selector: (_, provider) => provider.tables,
        builder: (context, tables, __) {
          return Column(
            children: [
              Expanded(
                child: EditTable(
                  onAdd: () {
                    _tableController.clear();
                    ConfirmFutureDialog(
                      onStatusConfirmFuture: () {
                        return Provider.of<GameTableProvider>(context, listen: false).insertTable(
                          null,
                          _tableController.text,
                        );
                      },
                      style: ConfirmDialogStyle.success(
                        title: "Add Table",
                        message: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _tableController,
                              decoration: const InputDecoration(
                                hintText: "Table Name",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).show(context);
                  },
                  headers: [
                    _buildCell(
                      const Text(
                        "Table",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _rows(context, tables),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
