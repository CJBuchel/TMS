import 'dart:io';
import 'dart:typed_data';

import 'package:tms/network/network.dart';

class ScheduleService {
  Future<int> uploadSchedule(Uint8List file) async {
    try {
      var request = file;
      var response = await Network().networkPost("/tournament/schedule/csv", request);
      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      return HttpStatus.badRequest;
    }
  }
}
