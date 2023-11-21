import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/responsive.dart';
import 'package:tms/utils/value_listenable_utils.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

class RefereeTable {
  final String referee;
  final String table;

  RefereeTable(this.referee, this.table);
}

class RefereeTableUtil {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  static Future<void> setRefereeName(String referee) async {
    await _localStorage.then((value) => value.setString(storeRefereeName, referee));
  }

  static Future<String> getRefereeName() async {
    try {
      var referee = await _localStorage.then((value) => value.getString(storeRefereeName));
      if (referee != null) {
        return referee;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static Future<void> setTable(String table) async {
    await _localStorage.then((value) => value.setString(storeRefereeTable, table));
  }

  static Future<String> getTable() async {
    try {
      var table = await _localStorage.then((value) => value.getString(storeRefereeTable));
      if (table != null) {
        return table;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Get Tuple2<Referee, Table>
  static Future<RefereeTable> getRefereeTable() async {
    try {
      var referee = await getRefereeName();
      var table = await getTable();
      return RefereeTable(referee, table);
    } catch (e) {
      return RefereeTable("", "");
    }
  }
}

class TableSetup extends StatefulWidget {
  const TableSetup({Key? key}) : super(key: key);

  @override
  State<TableSetup> createState() => _TableSetupState();
}

class _TableSetupState extends State<TableSetup> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<List<String>> _eventTablesNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<String?> _selectedTableNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedRefereeNotifier = ValueNotifier<String?>(null);

  // Color _buttonColor = Colors.grey;
  final TextEditingController _refereeNameController = TextEditingController();

  void setEventTables(List<String> tables) {
    if (!listEquals(_eventTablesNotifier.value, tables)) {
      _eventTablesNotifier.value = tables;
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEventTables(event.tables));
  }

  Widget getButton() {
    return ValueListenableBuilder2(
      first: _selectedRefereeNotifier,
      second: _selectedTableNotifier,
      builder: (context, selectedReferee, selectedTable, _) {
        Color buttonColor = Colors.grey;

        if (selectedReferee != null && selectedTable != null) {
          if (selectedReferee.isNotEmpty && selectedTable.isNotEmpty) {
            buttonColor = Colors.blue;
          }
        }

        return ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
          ),
          onPressed: () {
            if (selectedTable != null && selectedReferee != null) {
              RefereeTableUtil.setTable(selectedTable).then((tableVoid) {
                RefereeTableUtil.setRefereeName(selectedReferee).then((refereeVoid) {
                  Navigator.pushReplacementNamed(context, '/referee/scoring');
                });
              });
            }
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text("Continue"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logos/TMS_LOGO.png',
                height: Responsive.imageSize(context, 1).item1,
                width: Responsive.imageSize(context, 1).item2,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.imageSize(context, 1).item2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
                  child: TextField(
                    onChanged: (value) {
                      if (_selectedRefereeNotifier.value != value) {
                        _selectedRefereeNotifier.value = value;
                      }
                    },
                    controller: _refereeNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Referee',
                      hintText: 'Enter your name e.g `Monika`',
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            width: Responsive.imageSize(context, 1).item2,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
              child: ValueListenableBuilder2(
                first: _eventTablesNotifier,
                second: _selectedTableNotifier,
                builder: (context, eventTables, selectedTable, _) {
                  return DropdownButton<String>(
                    value: selectedTable,
                    hint: const Text('Select Table'),
                    onChanged: (String? value) {
                      if (selectedTable != value) {
                        _selectedTableNotifier.value = value;
                      }
                    },
                    items: eventTables.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.buttonWidth(context, 1),
                height: Responsive.buttonHeight(context, 1),
                child: getButton(),
              )
            ],
          )
        ],
      ),
    );
  }
}
