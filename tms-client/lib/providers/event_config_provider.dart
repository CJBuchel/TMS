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

  String get eventName => this.items["config"]?.name ?? "";
  int get timerLength => this.items["config"]?.timerLength ?? 150;
  int get endGameTimerLength => this.items["config"]?.endGameTimerLength ?? 30;
  int get backupInterval => this.items["config"]?.backupInterval ?? 5;
  int get retainBackups => this.items["config"]?.retainBackups ?? 5;
  String get season => this.items["config"]?.season ?? "";

  Future<int> setEventName(String name) async {
    TmsLogger().d("Setting event name to $name");
    int status = await _service.setEventName(name);
    return status;
  }

  Future<int> setTimerLength(int timerLength) async {
    TmsLogger().d("Setting timer length to $timerLength");
    int status = await _service.setTimerLength(timerLength);
    return status;
  }

  Future<int> setEndgameTimerLength(int endgameTimerLength) async {
    TmsLogger().d("Setting endgame timer length to $endgameTimerLength");
    int status = await _service.setEndgameTimerLength(endgameTimerLength);
    return status;
  }

  Future<int> setBackupInterval(int backupInterval) async {
    TmsLogger().d("Setting backup interval to $backupInterval");
    int status = await _service.setBackupInterval(backupInterval);
    return status;
  }

  Future<int> setRetainBackups(int retainBackups) async {
    TmsLogger().d("Setting retain backups to $retainBackups");
    int status = await _service.setRetainBackups(retainBackups);
    return status;
  }

  Future<int> setSeason(String season) async {
    TmsLogger().d("Setting season to $season");
    int status = await _service.setSeason(season);
    return status;
  }

  Future<int> purgeEvent() async {
    TmsLogger().d("Purging event");
    int status = await _service.purge();
    return status;
  }
}
