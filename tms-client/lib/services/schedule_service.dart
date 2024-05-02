import 'dart:io';
import 'dart:typed_data';

import 'package:tms/network/network.dart';

class ScheduleService {
  Future<int> uploadSchedule(Uint8List csv) async {
    try {
      var request = csv;
      var response = await Network().networkPost("/tournament/schedule/csv", request, encode: false);
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
