import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_table_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/popup_dialog.dart';

class GameTableInfo extends StatelessWidget {
  final ValueNotifier<String> selectedTable = ValueNotifier<String>("");

  void selectTable(BuildContext context, String currentTable, List<String> tables) {
    if (tables.isEmpty) {
      PopupDialog.warn(
        title: "No Tables",
        message: "No tables found in the database",
      ).show(context);
    } else {
      if (tables.contains(currentTable)) {
        selectedTable.value = currentTable;
      } else {
        selectedTable.value = tables.first;
      }

      ConfirmDialog(
        style: ConfirmDialogStyle.info(
          title: "Select Table",
          message: ValueListenableBuilder<String>(
            valueListenable: selectedTable,
            builder: (context, value, _) {
              return DropdownButton<String>(
                value: value,
                items: tables.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) selectedTable.value = value;
                },
              );
            },
          ),
        ),
        onConfirm: () {
          Provider.of<GameTableProvider>(context, listen: false).localGameTable = selectedTable.value;
        },
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":robot_game:tables"],
      child: Selector<GameTableProvider, ({bool isTableSet, String currentTableName, List<String> tableNames})>(
        selector: (context, provider) {
          return (
            isTableSet: provider.isLocalGameTableSet(),
            currentTableName: provider.localGameTable,
            tableNames: provider.tableNames,
          );
        },
        builder: (context, data, _) {
          // select table micro task
          if (!data.isTableSet) {
            Future.microtask(() {
              selectTable(context, data.currentTableName, data.tableNames);
            });
          }

          return TextButton(
            onPressed: () {
              selectTable(context, data.currentTableName, data.tableNames);
            },
            child: Text(
              data.isTableSet ? data.currentTableName : "No Table Selected",
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
