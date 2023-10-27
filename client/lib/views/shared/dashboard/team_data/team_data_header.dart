import 'package:flutter/material.dart';
import 'package:tms/views/shared/dashboard/team_data/export_data.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table_types.dart';
import 'package:tms/views/shared/edit_checkbox.dart';

class TeamDataHeader extends StatefulWidget {
  final ValueNotifier<List<TDColumn>> columns;
  final ValueNotifier<List<TDRow>> rows;

  const TeamDataHeader({
    Key? key,
    required this.columns,
    required this.rows,
  }) : super(key: key);

  @override
  State<TeamDataHeader> createState() => _TeamDataHeaderState();
}

class _TeamDataHeaderState extends State<TeamDataHeader> {
  List<TDColumn> _columns = [];

  @override
  void didUpdateWidget(covariant TeamDataHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _columns = List.from(widget.columns.value);
  }

  @override
  void initState() {
    super.initState();
    _columns = List.from(widget.columns.value);
  }

  void showDataFilter() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.blue),
              SizedBox(width: 10),
              Text('Table Columns', style: TextStyle(color: Colors.blue)),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              itemCount: _columns.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_columns[index].label),
                      ),
                      EditCheckbox(
                        value: _columns[index].show,
                        onChanged: (value) {
                          setState(() {
                            _columns[index].show = value;
                          });
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.columns.value = List.from(_columns);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 50,
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  showDataFilter();
                },
                icon: const Icon(Icons.filter_alt, size: 18),
                label: const Text('Columns'),
              ),
              ValueListenableBuilder(
                valueListenable: widget.rows,
                builder: (context, rows, child) {
                  return ValueListenableBuilder(
                    valueListenable: widget.columns,
                    builder: (context, columns, child) {
                      return ExportTeamDataButton(columns: columns, rows: rows);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
