import 'dart:io';

import 'package:tms/network/network.dart';
import 'package:tms/schemas/network_schema.dart';
import 'package:tms/utils/logger.dart';

class EventConfigService {
  Future<int> setEventName(String name) async {
    try {
      var request = TournamentConfigSetNameRequest(name: name).toJson();
      var response = await Network().networkPost("/tournament/config/name", request);
      if (response.$1) {
        TmsLogger().i("Event name set to $name");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> setTimerLength(int timerLength) async {
    try {
      var request = TournamentConfigSetTimerLengthRequest(timerLength: timerLength).toJson();
      var response = await Network().networkPost("/tournament/config/timer_length", request);
      if (response.$1) {
        TmsLogger().i("Timer length set to $timerLength");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> setEndgameTimerLength(int endgameTimerLength) async {
    try {
      var request = TournamentConfigSetEndgameTimerLengthRequest(timerLength: endgameTimerLength).toJson();
      var response = await Network().networkPost("/tournament/config/endgame_timer_length", request);
      if (response.$1) {
        TmsLogger().i("Endgame timer length set to $endgameTimerLength");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> setBackupInterval(int backupInterval) async {
    try {
      var request = TournamentConfigSetBackupIntervalRequest(interval: backupInterval).toJson();
      var response = await Network().networkPost("/tournament/config/backup_interval", request);
      if (response.$1) {
        TmsLogger().i("Backup interval set to $backupInterval");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> setRetainBackups(int retainBackups) async {
    try {
      var request = TournamentConfigSetRetainBackupsRequest(retainBackups: retainBackups).toJson();
      var response = await Network().networkPost("/tournament/config/retain_backups", request);
      if (response.$1) {
        TmsLogger().i("Backup retention set to $retainBackups");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> setSeason(String season) async {
    try {
      var request = TournamentConfigSetSeasonRequest(season: season).toJson();
      var response = await Network().networkPost("/tournament/config/season", request);
      if (response.$1) {
        TmsLogger().i("Season set to $season");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
