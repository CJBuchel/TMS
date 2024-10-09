import 'package:flutter/material.dart';
import 'package:tms/models/team_data_model.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/converters.dart';
import 'package:tms/views/team_data/export_button.dart';
import 'package:tms/views/team_data/filter_header_cell.dart';
import 'package:tms/views/team_data/filter_row_cell.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:collection/collection.dart';

class TeamDataFilterTable extends StatefulWidget {
  final int maxNumberRounds;
  final List<TeamDataModel> teamData;

  const TeamDataFilterTable({
    required this.maxNumberRounds,
    required this.teamData,
  });

  @override
  _TeamDataFilterTableState createState() => _TeamDataFilterTableState();
}

class _TeamDataFilterTableState extends State<TeamDataFilterTable> {
  Map<String, FilterColumn> _columns = {};
  Map<String, String> _filters = {};

  @override
  void initState() {
    super.initState();
    _initializeColumns();
  }

  @override
  void didUpdateWidget(covariant TeamDataFilterTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeColumns();
  }

  void _initializeColumns() {
    _columns.putIfAbsent(
      "rank",
      () => FilterColumn(
        label: "Rank",
        show: true,
        flex: 1,
        onFilterChanged: (value) => _onFilterChanged("rank", value),
      ),
    );

    _columns.putIfAbsent(
      "teamNumber",
      () => FilterColumn(
        label: "Team #",
        show: true,
        flex: 1,
        onFilterChanged: (value) => _onFilterChanged("teamNumber", value),
      ),
    );

    _columns.putIfAbsent(
      "teamName",
      () => FilterColumn(
        label: "Team Name",
        show: true,
        flex: 3,
        onFilterChanged: (value) => _onFilterChanged("teamName", value),
      ),
    );

    for (var i = 1; i <= widget.maxNumberRounds; i++) {
      _columns.putIfAbsent(
        "r${i}_score",
        () => FilterColumn(
          label: "R$i Score",
          show: true,
          flex: 1,
          onFilterChanged: (value) => _onFilterChanged("r${i}_score", value),
        ),
      );

      _columns.putIfAbsent(
        "r${i}_gp",
        () => FilterColumn(
          label: "R$i GP",
          show: true,
          flex: 1,
          onFilterChanged: (value) => _onFilterChanged("r${i}_gp", value),
        ),
      );

      _columns.putIfAbsent(
        "r${i}_comment",
        () => FilterColumn(
          label: "R$i Comment",
          show: false,
          flex: 3,
          onFilterChanged: (value) => _onFilterChanged("r${i}_comment", value),
        ),
      );
    }
  }

  void _onFilterChanged(String key, String value) {
    setState(() {
      _filters[key] = value;
    });
  }

  void _onColumnVisibilityChanged(String key, bool value) {
    setState(() {
      _columns[key] = FilterColumn(
        label: _columns[key]!.label,
        show: value,
        flex: _columns[key]!.flex,
        onFilterChanged: _columns[key]!.onFilterChanged,
      );
    });
  }

  void _showColumnSelectionDialog() {
    Map<String, bool> columnVisibility = Map.fromEntries(
      _columns.entries.map((entry) => MapEntry(entry.key, entry.value.show)),
    );

    ConfirmDialog(
      style: ConfirmDialogStyle.info(
        title: "Select Columns",
        message: SingleChildScrollView(
          child: Column(
            children: columnVisibility.keys.map((key) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(key),
                  LiveCheckbox(
                    defaultValue: columnVisibility[key] ?? false,
                    onChanged: (value) {
                      columnVisibility[key] = value;
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      onConfirm: () {
        setState(() {
          columnVisibility.forEach((key, value) {
            _onColumnVisibilityChanged(key, value);
          });
        });
      },
    ).show(context);
  }

  Color _getColor(int i) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.orange,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];

    return colors[i % colors.length].withOpacity(0.2);
  }

  bool _applyFilters(TeamDataModel data) {
    if (_filters["rank"] != null &&
        _filters["rank"]!.isNotEmpty &&
        (!data.team.ranking.toString().toLowerCase().contains(_filters["rank"]!.toLowerCase()) ||
            data.team.ranking.toString().isEmpty)) {
      return false;
    }
    if (_filters["teamNumber"] != null &&
        _filters["teamNumber"]!.isNotEmpty &&
        (!data.team.teamNumber.toLowerCase().contains(_filters["teamNumber"]!.toLowerCase()) ||
            data.team.teamNumber.isEmpty)) {
      return false;
    }
    if (_filters["teamName"] != null &&
        _filters["teamName"]!.isNotEmpty &&
        (!data.team.name.toLowerCase().contains(_filters["teamName"]!.toLowerCase()) || data.team.name.isEmpty)) {
      return false;
    }
    for (var i = 1; i <= widget.maxNumberRounds; i++) {
      var score = data.scores.firstWhereOrNull((element) => element.round == i);
      if (score != null) {
        if (_filters["r${i}_score"] != null &&
            _filters["r${i}_score"]!.isNotEmpty &&
            (!score.score.toString().toLowerCase().contains(_filters["r${i}_score"]!.toLowerCase()) ||
                score.score.toString().isEmpty)) {
          return false;
        }
        if (_filters["r${i}_gp"] != null &&
            _filters["r${i}_gp"]!.isNotEmpty &&
            (!convertGpToInt(score.gp).toString().toLowerCase().contains(_filters["r${i}_gp"]!.toLowerCase()) ||
                convertGpToInt(score.gp).toString().isEmpty)) {
          return false;
        }
        if (_filters["r${i}_comment"] != null &&
            _filters["r${i}_comment"]!.isNotEmpty &&
            (!score.privateComment.toLowerCase().contains(_filters["r${i}_comment"]!.toLowerCase()) ||
                score.privateComment.isEmpty)) {
          return false;
        }
      } else {
        if ((_filters["r${i}_score"] != null && _filters["r${i}_score"]!.isNotEmpty) ||
            (_filters["r${i}_gp"] != null && _filters["r${i}_gp"]!.isNotEmpty) ||
            (_filters["r${i}_comment"] != null && _filters["r${i}_comment"]!.isNotEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  List<BaseTableCell> _buildHeaderCells() {
    return _columns.values.where((column) => column.show).map((column) => column).toList();
  }

  List<BaseTableRow> _buildRows(BuildContext context) {
    List<BaseTableRow> rows = [];

    int index = 0;
    for (var data in widget.teamData) {
      if (_applyFilters(data)) {
        List<BaseTableCell> rowCells = [];
        _columns.forEach((key, column) {
          if (column.show) {
            if (key == "rank") {
              rowCells.add(FilterRowCell(
                context: context,
                text: data.team.ranking.toString(),
                flex: column.flex,
              ));
            } else if (key == "teamNumber") {
              rowCells.add(FilterRowCell(
                context: context,
                text: data.team.teamNumber,
                flex: column.flex,
              ));
            } else if (key == "teamName") {
              rowCells.add(FilterRowCell(
                context: context,
                text: data.team.name,
                flex: column.flex,
              ));
            } else {
              for (var i = 1; i <= widget.maxNumberRounds; i++) {
                if (key == "r${i}_score") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  rowCells.add(FilterRowCell(
                    context: context,
                    text: score?.score.toString() ?? "",
                    flex: column.flex,
                    color: _getColor(i),
                  ));
                } else if (key == "r${i}_gp") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  String text = "";

                  if (score?.gp.isEmpty ?? true) {
                    text = "";
                  } else {
                    text = convertGpToInt(score!.gp).toString();
                  }

                  rowCells.add(FilterRowCell(
                    context: context,
                    text: text,
                    flex: column.flex,
                    color: _getColor(i),
                  ));
                } else if (key == "r${i}_comment") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  rowCells.add(FilterRowCell(
                    context: context,
                    text: score?.privateComment ?? "",
                    flex: column.flex,
                    color: _getColor(i),
                  ));
                }
              }
            }
          }
        });

        Color evenColor = Theme.of(context).cardColor;
        Color oddColor = lighten(Theme.of(context).cardColor, 0.05);
        Color rowColor = index % 2 == 0 ? evenColor : oddColor;

        rows.add(
          BaseTableRow(
            cells: rowCells,
            decoration: BoxDecoration(
              color: rowColor,
            ),
          ),
        );

        index++;
      }
    }

    return rows;
  }

  List<List<String>> _getFilteredData() {
    List<List<String>> csvData = [];

    // Add headers
    List<String> headers = _columns.values.where((column) => column.show).map((column) => column.label).toList();
    csvData.add(headers);

    // Add rows
    for (var data in widget.teamData) {
      if (_applyFilters(data)) {
        List<String> row = [];
        _columns.forEach((key, column) {
          if (column.show) {
            if (key == "rank") {
              row.add(data.team.ranking.toString());
            } else if (key == "teamNumber") {
              row.add(data.team.teamNumber);
            } else if (key == "teamName") {
              row.add(data.team.name);
            } else {
              for (var i = 1; i <= widget.maxNumberRounds; i++) {
                if (key == "r${i}_score") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  row.add(score?.score.toString() ?? "");
                } else if (key == "r${i}_gp") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  if (score?.gp.isEmpty ?? true) {
                    row.add("");
                  } else {
                    row.add(convertGpToInt(score?.gp ?? "").toString());
                  }
                } else if (key == "r${i}_comment") {
                  var score = data.scores.firstWhereOrNull((element) => element.round == i);
                  row.add(score?.privateComment ?? "");
                }
              }
            }
          }
        });
        csvData.add(row);
      }
    }

    return csvData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  overlayColor: Colors.blue[900],
                  shadowColor: Colors.blue[900],
                  surfaceTintColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.filter_alt),
                label: const Text("Columns"),
                onPressed: () => _showColumnSelectionDialog(),
              ),
              ExportButton(data: _getFilteredData()),
            ],
          ),
        ),
        Expanded(
          child: BaseTable(
            headers: _buildHeaderCells(),
            rows: _buildRows(context),
          ),
        ),
      ],
    );
  }
}
