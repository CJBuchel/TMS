import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_table.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/table_state_event.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/utils/logger.dart';

class GameTableSignalProvider extends EchoTreeProvider<String, GameTable> with ServerEventSubscribeNotifierMixin {
  final Map<String, String> _tableSignals = {};

  void _updateTableSignals(String table, String teamNumber) {
    // update or add table signal
    _tableSignals[table] = teamNumber;
    notifyListeners();
  }

  GameTableSignalProvider()
      : super(
          tree: ":robot_game:tables",
          fromJsonString: (json) => GameTable.fromJsonString(json: json),
        ) {
    subscribeToEvent(TmsServerSocketEvent.tableStateEvent, (event) {
      if (event.message != null) {
        // handle table state event
        try {
          TmsServerTableStateEvent tableStateEvent = TmsServerTableStateEvent.fromJsonString(json: event.message!);
          _updateTableSignals(tableStateEvent.table, tableStateEvent.teamNumber);
        } catch (e) {
          TmsLogger().e("Error parsing table state event: $e");
        }
      }
    });
  }

  Map<String, String> get tableSignals => _tableSignals;
}
