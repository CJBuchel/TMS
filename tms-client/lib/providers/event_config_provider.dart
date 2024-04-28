import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/db/echo_tree_notifier.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/services/event_config_service.dart';
import 'package:tms/utils/logger.dart';

class EventConfigProvider extends EchoTreeNotifier<String, TournamentConfig> {
  EventConfigProvider()
      : super(
          managedTree: Database().getTreeMap.getTree(":tournament:config"),
          fromJson: (json) => TournamentConfig.fromJson(json),
        );

  EventConfigService _service = EventConfigService();

  String get eventName => this.items["config"]?.name ?? "";

  Future<int> setEventName(String name) async {
    TmsLogger().d("Setting event name to $name");
    int status = await _service.setEventName(name);
    // notifyListeners();
    return status;
  }
}
