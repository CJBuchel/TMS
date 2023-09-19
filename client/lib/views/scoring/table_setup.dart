import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/tool_bar.dart';

class RefereeTableUtil {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

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
}

class TableSetup extends StatefulWidget {
  const TableSetup({Key? key}) : super(key: key);

  @override
  State<TableSetup> createState() => _TableSetupState();
}

class _TableSetupState extends State<TableSetup> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<String> _eventTables = [];
  String? _selectedTable;
  Color _buttonColor = Colors.grey;
  final TextEditingController _refereeNameController = TextEditingController();

  void setEventTables(List<String> tables) {
    setState(() {
      _eventTables = tables;
    });
  }

  void checkIfValid() {
    if (_refereeNameController.value.text.isNotEmpty && _selectedTable != null) {
      setState(() {
        _buttonColor = Colors.blue;
      });
    } else {
      setState(() {
        _buttonColor = Colors.grey;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEventTables(event.tables));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
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
                    onChanged: (value) => checkIfValid(),
                    controller: _refereeNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Referee',
                      hintText: 'Enter your name e.g `Nathan`',
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
              child: DropdownButton<String>(
                value: _selectedTable,
                hint: const Text('Select Table'),
                onChanged: (String? value) {
                  setState(() {
                    _selectedTable = value;
                    checkIfValid();
                  });
                },
                items: _eventTables.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Responsive.buttonWidth(context, 1),
                height: Responsive.buttonHeight(context, 1),
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(_buttonColor),
                  ),
                  onPressed: () {
                    if (_selectedTable != null && _refereeNameController.value.text.isNotEmpty) {
                      RefereeTableUtil.setTable(_selectedTable!).then((value) {
                        Navigator.pushReplacementNamed(context, '/referee/scoring');
                      });
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Continue"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
