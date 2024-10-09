import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';

class _GameTableData {
  final bool isTableSet;
  final String currentTableName;
  final List<String> tableNames;
  final String currentReferee;

  _GameTableData({
    required this.isTableSet,
    required this.currentTableName,
    required this.tableNames,
    required this.currentReferee,
  });
}

class SelectGameTable extends StatefulWidget {
  final double fontSize;

  const SelectGameTable({
    Key? key,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  State<SelectGameTable> createState() => _SelectGameTableState();
}

class _SelectGameTableState extends State<SelectGameTable> {
  final ValueNotifier<String> selectedTable = ValueNotifier<String>("");

  void selectTable(BuildContext context, String currentTable, List<String> tables, String currentReferee) {
    final refereeController = TextEditingController(text: currentReferee);

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
        message: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // dropdown table
              ValueListenableBuilder<String>(
                valueListenable: selectedTable,
                builder: (context, value, _) {
                  return SizedBox(
                    width: 300,
                    child: DropdownButton<String>(
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
                    ),
                  );
                },
              ),
              // space
              const SizedBox(height: 20),
              // referee
              TextField(
                controller: refereeController,
                decoration: const InputDecoration(
                  labelText: "Input Referee",
                ),
              ),
            ],
          ),
        ),
      ),
      onConfirm: () {
        Provider.of<GameTableProvider>(context, listen: false).localGameTable = selectedTable.value;
        Provider.of<GameTableProvider>(context, listen: false).localReferee = refereeController.text;
      },
    ).show(context);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (!mounted) return;
      final provider = Provider.of<GameTableProvider>(context, listen: false);
      if (!provider.isLocalGameTableSet()) {
        selectTable(context, provider.localGameTable, provider.tableNames, provider.localReferee);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameTableProvider, _GameTableData>(
      selector: (context, provider) {
        return _GameTableData(
          isTableSet: provider.isLocalGameTableSet(),
          currentTableName: provider.localGameTable,
          tableNames: provider.tableNames,
          currentReferee: provider.localReferee,
        );
      },
      builder: (context, data, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(10, 0, 10, 0)),
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
              selectTable(context, data.currentTableName, data.tableNames, data.currentReferee);
            },
            child: Text(
              data.isTableSet ? data.currentTableName : "No Table Selected",
              style: TextStyle(
                fontSize: widget.fontSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
