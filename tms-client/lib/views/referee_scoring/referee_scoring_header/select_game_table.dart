import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_table_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';

class SelectGameTable extends StatefulWidget {
  const SelectGameTable({Key? key}) : super(key: key);

  @override
  State<SelectGameTable> createState() => _SelectGameTableState();
}

class _SelectGameTableState extends State<SelectGameTable> {
  final ValueNotifier<String> selectedTable = ValueNotifier<String>("");
  final ValueNotifier<bool> showDialog = ValueNotifier<bool>(false);

  void selectTable(BuildContext context, String currentTable, List<String> tables) {
    if (tables.isEmpty) {
      return;
    }

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

  @override
  void initState() {
    super.initState();
    showDialog.value = true;
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
          return ValueListenableBuilder(
            valueListenable: this.showDialog,
            builder: (context, show, _) {
              if (show) {
                // check if we need to show dialog
                Future.microtask(() {
                  if (data.tableNames.isEmpty || data.currentTableName.isEmpty) {
                    showDialog.value = false;
                    selectTable(context, data.currentTableName, data.tableNames);
                  }
                });
              }

              return TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(10, 2, 10, 2)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  selectTable(context, data.currentTableName, data.tableNames);
                },
                child: Text(
                  data.isTableSet ? data.currentTableName : "No Table Selected",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
