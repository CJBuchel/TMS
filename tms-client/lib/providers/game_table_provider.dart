import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_table.dart';
import 'package:tms/providers/local_storage_provider.dart';

class GameTableProvider extends EchoTreeProvider<String, GameTable> {
  String _localGameTable = "";

  void _onStorageChange() {
    if (_localGameTable != TmsLocalStorageProvider().gameTable) {
      _localGameTable = TmsLocalStorageProvider().gameTable;
      notifyListeners();
    }
  }

  GameTableProvider()
      : super(
          tree: ":robot_game:tables",
          fromJsonString: (json) => GameTable.fromJsonString(json: json),
        ) {
    _localGameTable = TmsLocalStorageProvider().gameTable;
    TmsLocalStorageProvider().addListener(_onStorageChange);
  }

  List<GameTable> get tables => this.items.values.toList();
  List<String> get tableNames => this.items.values.map((e) => e.tableName).toList();

  // check if table is set in local storage
  // and if the table exists in the db
  bool isLocalGameTableSet() {
    bool isTableSet = _localGameTable.isNotEmpty;
    bool doesTableExist = this.items.containsValue(GameTable(tableName: _localGameTable));
    return isTableSet && doesTableExist;
  }

  String get localGameTable {
    return _localGameTable;
  }

  set localGameTable(String table) {
    _localGameTable = table;
    TmsLocalStorageProvider().gameTable = table;
    notifyListeners();
  }

  void clearLocalTable() {
    _localGameTable = "";
    TmsLocalStorageProvider().gameTable = "";
    notifyListeners();
  }
}
