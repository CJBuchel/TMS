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
}
