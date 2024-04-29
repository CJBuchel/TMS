import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/schemas/database_schema.dart';
import 'package:tms/services/event_config_service.dart';
import 'package:tms/utils/logger.dart';

class EventConfigProvider extends EchoTreeProvider<String, TournamentConfig> {
  EventConfigProvider()
      : super(
          tree: ":tournament:config",
          fromJson: (json) => TournamentConfig.fromJson(json),
        );

  EventConfigService _service = EventConfigService();

  String get eventName => this.items["config"]?.name ?? "N/A";

  Future<int> setEventName(String name) async {
    TmsLogger().d("Setting event name to $name");
    int status = await _service.setEventName(name);
    return status;
  }
}
